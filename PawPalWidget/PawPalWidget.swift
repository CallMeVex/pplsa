import SwiftUI
import WidgetKit

struct PawPalEntry: TimelineEntry {
    let date: Date
    let petName: String
    let hunger: Int
    let moodEmoji: String
}

struct PawPalProvider: TimelineProvider {
    func placeholder(in context: Context) -> PawPalEntry {
        PawPalEntry(date: .init(), petName: "Milo", hunger: 42, moodEmoji: "😊")
    }

    func getSnapshot(in context: Context, completion: @escaping (PawPalEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PawPalEntry>) -> Void) {
        let entry = placeholder(in: context)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct PawPalWidgetView: View {
    var entry: PawPalProvider.Entry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.petName).font(.headline)
            Text("Hunger: \(entry.hunger)")
            Text(entry.moodEmoji)
        }
        .widgetURL(URL(string: "pawpal://pet"))
    }
}

struct PawPalWidget: Widget {
    let kind: String = "PawPalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PawPalProvider) { entry in
            PawPalWidgetView(entry: entry)
        }
        .configurationDisplayName("PawPal")
        .description("See pet mood and hunger at a glance.")
        .supportedFamilies([.accessoryRectangular])
    }
}

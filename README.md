# PawPal MVP (iOS + Supabase)

PawPal is a SwiftUI iOS 16+ virtual pet co-parenting app MVP with authentication, onboarding, pet care gameplay, co-parenting data model, leaderboard, profile, monetization hooks, notifications, and lock screen widget scaffolding.

## Tech Stack

- Swift / SwiftUI (iOS 16+)
- Supabase (Auth, Postgres, Realtime-ready tables, Storage-ready schema)
- RevenueCat (IAP/subscription integration wrapper)
- APNS (notification permission + scheduling scaffold)
- WidgetKit (accessory lock screen widget)
- MVVM + Combine
- Async/await for async flows

## Project Structure

```text
PawPal/
├── PawPal/
│   ├── PawPalApp.swift
│   ├── ContentView.swift
│   ├── Models/
│   ├── ViewModels/
│   ├── Views/
│   ├── Services/
│   ├── Utilities/
│   ├── Extensions/
│   └── Resources/
├── PawPalWidget/
│   └── PawPalWidget.swift
├── supabase_schema.sql
└── README.md
```

## Xcode Setup

1. Open Xcode 15+ and create a new **iOS App** named `PawPal` (SwiftUI, Swift, iOS 16 deployment target).
2. Copy the `PawPal/` source folder from this repository into your Xcode project navigator (replace generated files).
3. Add a new Widget Extension target named `PawPalWidget` and replace its main widget file with `PawPalWidget/PawPalWidget.swift`.
4. Add Swift Package dependencies:
   - `https://github.com/supabase/supabase-swift`
   - `https://github.com/RevenueCat/purchases-ios`
5. In Signing & Capabilities, enable:
   - Sign in with Apple
   - Push Notifications
   - Background Modes (`Remote notifications`, `Background fetch`)
6. Add URL scheme `pawpal` for widget deep links (`pawpal://pet`).

## Supabase Setup

1. Create a new Supabase project.
2. Go to **SQL Editor** and paste `supabase_schema.sql`.
3. Run the SQL.
4. In **Project Settings > API**, copy:
   - Project URL
   - anon public key
5. Update `PawPal/Utilities/Constants.swift`:
   - `supabaseURL`
   - `supabaseAnonKey`
6. In **Authentication > Providers**, enable:
   - Email
   - Apple
7. Configure Apple OAuth redirect URL from Supabase in Apple Developer portal.

## RevenueCat Setup

1. Create RevenueCat project and iOS app.
2. Create offerings and products:
   - Paws bundles: 500, 1200, 3000, 7500, 20000
   - Premium monthly/yearly
   - Streak saver pack (5)
3. Copy public SDK key and set `revenueCatAPIKey` in `Constants.swift`.
4. Configure App Store Connect products to match RevenueCat identifiers.
5. Add RevenueCat webhook endpoint (Supabase Edge Function recommended) to write purchases into `public.purchases` and update profile entitlements.

## APNS Setup

1. In Apple Developer, create APNS key (recommended) or certificates.
2. Upload APNS key in:
   - App Store Connect (app)
   - Optional: notification provider backend (for travel and care notifications)
3. In Xcode target capabilities, ensure Push Notifications + Background Modes are enabled.
4. Add notification registration in app lifecycle as needed for production push token handling and save device token into `public.device_tokens`.

## Running the App

### Simulator

- Email/password auth flows and most UI/gameplay flows work.
- Apple Sign-in may require simulator iCloud account.
- APNS remote push is limited; local scheduled notifications work.
- RevenueCat test purchases use StoreKit config/sandbox.

### Physical Device

- Required for complete APNS and Apple Sign-in validation.
- Use sandbox Apple ID for IAP tests.
- Validate widget lock screen behavior directly on device.

## MVP Notes / Known Limitations

- Travel decision engine is scaffolded in utility logic; server-side scheduler/edge function should trigger travel updates and push delivery.
- Pet favorite food is hidden in data but currently randomized at hatch and partially simulated in care action logic.
- Widget currently uses placeholder timeline data; connect to App Group/shared storage for live pet state.
- Delete account flow should be moved to privileged Supabase Edge Function for secure auth user deletion.
- Background decay should be finalized with BGTaskScheduler for robust execution when app is not active.

## What to Build Next

- Complete realtime co-parent sync/event broadcasting with Supabase Realtime channels.
- Add robust onboarding polish (animations/confetti/Lottie assets and tooltip overlays).
- Implement full purchase surfaces and entitlement-gated premium UI.
- Add image/avatar storage uploads with Supabase Storage.
- Add automated tests:
  - Unit tests for `PetLogic`, `XPCalculator`, `StreakManager`
  - Integration tests for auth/pet service methods
  - Snapshot tests for core SwiftUI screens

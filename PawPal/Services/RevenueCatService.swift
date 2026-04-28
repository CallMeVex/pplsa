import Foundation
import RevenueCat

final class RevenueCatService {
    static let shared = RevenueCatService()
    private init() {}

    func configure(userId: String?) {
        Purchases.configure(withAPIKey: AppConstants.revenueCatAPIKey, appUserID: userId)
    }

    func fetchOfferings() async throws -> Offerings {
        try await Purchases.shared.offerings()
    }

    func purchase(package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        return result.customerInfo
    }

    func restore() async throws -> CustomerInfo {
        try await Purchases.shared.restorePurchases()
    }
}

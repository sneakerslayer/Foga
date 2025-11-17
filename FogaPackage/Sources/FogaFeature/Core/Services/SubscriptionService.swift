import Foundation
import StoreKit
import Combine

/// Service for managing in-app subscriptions
/// 
/// **Learning Note**: StoreKit 2 is Apple's framework for in-app purchases.
/// This service handles subscription management (premium features).
/// 
/// **How subscriptions work**:
/// 1. User taps "Subscribe" button
/// 2. StoreKit shows Apple's purchase dialog
/// 3. User authenticates with Face ID/Touch ID
/// 4. Apple processes payment
/// 5. App receives confirmation and unlocks premium features
@available(iOS 15.0, *)
@MainActor
public class SubscriptionService: ObservableObject {
    /// Current subscription status
    @Published public var isPremium: Bool = false
    
    /// Available subscription products
    @Published public var products: [Product] = []
    
    /// Loading state
    @Published public var isLoading: Bool = false
    
    /// Error message
    @Published public var errorMessage: String?
    
    /// Subscription product IDs (configured in App Store Connect)
    private let productIDs = [
        "com.foga.app.monthly",
        "com.foga.app.yearly"
    ]
    
    public init() {
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    /// Load available subscription products
    /// 
    /// **Learning Note**: Products must be configured in App Store Connect first.
    /// This fetches the products Apple has configured for your app.
    @MainActor
    public func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    /// Purchase a subscription
    public func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkSubscriptionStatus()
                return true
                
            case .userCancelled:
                return false
                
            case .pending:
                errorMessage = "Purchase is pending approval"
                return false
                
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Check current subscription status
    /// 
    /// **Learning Note**: This checks if user has an active subscription.
    /// We check all current entitlements (subscriptions) the user has.
    public func checkSubscriptionStatus() async {
        var hasActiveSubscription = false
        
        // Check current entitlements for any of our subscription products
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement {
                if productIDs.contains(transaction.productID) {
                    hasActiveSubscription = true
                    break
                }
            }
        }
        
        isPremium = hasActiveSubscription
    }
    
    /// Verify transaction receipt
    /// 
    /// **Learning Note**: Always verify transactions with Apple's servers.
    /// This prevents fraud and ensures purchases are legitimate.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
}

/// Subscription errors
enum SubscriptionError: Error {
    case unverifiedTransaction
}


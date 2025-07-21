//
//  StoreManager.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/11/25.
//

import StoreKit
import Combine

// MARK: - Product Identifiers
enum ProductID: String, CaseIterable {
    case monthlySubscription = "com.artarriaga.speechtherapy.premium.monthly"
    
    static var allProductIDs: Set<String> {
        Set(ProductID.allCases.map { $0.rawValue })
    }
}

// MARK: - Store Manager
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isSubscribed = false
    @Published var isLoading = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        // Check initial subscription status
        Task {
            await updateSubscriptionStatus()
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    @MainActor
    func loadProducts() async {
        isLoading = true
        
        do {
            let storeProducts = try await Product.products(for: ProductID.allProductIDs)
            products = storeProducts
            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            isLoading = false
        }
    }
    
    // MARK: - Purchase Processing
    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            // Process the purchase and update subscription status
            let transaction = try checkVerified(verificationResult)
            await updatePurchasedProducts(transaction)
            await transaction.finish()
            await updateSubscriptionStatus()
            
        case .userCancelled:
            print("User cancelled the purchase")
            
        case .pending:
            print("Purchase is pending")
            
        @unknown default:
            print("Unknown purchase result")
        }
    }
    
    // MARK: - Subscription Status
    @MainActor
    func updateSubscriptionStatus() async {
        // Get all subscription statuses
        var isCurrentlySubscribed = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productType == .autoRenewable &&
                   ProductID.allProductIDs.contains(transaction.productID) {
                    isCurrentlySubscribed = true
                    break
                }
            } catch {
                print("Error verifying transaction: \(error)")
            }
        }
        
        // Update the subscription status
        isSubscribed = isCurrentlySubscribed
    }
    
    // MARK: - Transaction Handling
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts(transaction)
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                } catch {
                    print("Error processing transaction update: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    private func updatePurchasedProducts(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            // If the transaction is not revoked, add it to the list
            purchasedProductIDs.insert(transaction.productID)
        } else {
            // If the transaction is revoked, remove it from the list
            purchasedProductIDs.remove(transaction.productID)
        }
    }
    
    // MARK: - Helper Methods
    func monthlySubscriptionProduct() -> Product? {
        return products.first(where: { $0.id == ProductID.monthlySubscription.rawValue })
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
}

// MARK: - Errors
enum StoreError: Error {
    case failedVerification
    case unknownError
}

// Extension for StoreKit product helper methods
extension Product {
    // Get friendly display price
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceFormatStyle.locale
        
        // Fix: Simply use the price as NSNumber directly
        return formatter.string(from: price as NSNumber) ?? "\(price)"
    }
    
    // Get display name with fallback
    var displayName: String {
        // Fix: Based on the error in the StoreManager.swift file,
        // it seems like we need to use self.description instead of name
        // This avoids the recursion issue with displayName
        let title = self.description
        return title.isEmpty ? "Speech Therapy Premium" : title
    }
}

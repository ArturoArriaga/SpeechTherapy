import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @StateObject private var storeManager = StoreManager.shared
    @State private var showingRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var isRestoringPurchases = false
    
    var body: some View {
        List {
            // MARK: - Premium Features Section
            Section(header: Text("PREMIUM FEATURES")) {
                VStack(alignment: .leading, spacing: 16) {
                    // Subscription status indicator
                    HStack {
                        Text("Premium Phonemes")
                            .font(.headline)
                        
                        Spacer()
                        
                        if storeManager.isSubscribed {
                            Text("Active")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        } else {
                            Text("Inactive")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Subscription info
                    if !storeManager.isSubscribed {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unlock All Phonemes")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Only 3 phonemes (p, t, k) are available in the free version.")
                                .foregroundColor(.secondary)
                                .font(.callout)
                            
                            Text("Subscribe to unlock all 44 phonemes, blends, and advanced practice exercises.")
                                .foregroundColor(.secondary)
                                .font(.callout)
                            
                            // Price Display
                            if let product = storeManager.monthlySubscriptionProduct() {
                                Text("\(product.displayPrice)/month")
                                    .font(.headline)
                                    .padding(.vertical, 4)
                            }
                            
                            // Subscribe Button
                            subscribeButton
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    } else {
                        // Premium features list
                        VStack(alignment: .leading, spacing: 8) {
                            Label("All 44 phonemes unlocked", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.primary)
                            
                            Label("All consonant blends", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.primary)
                            
                            Label("Advanced practice exercises", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            isRestoringPurchases = true
                            await storeManager.restorePurchases()
                            isRestoringPurchases = false
                            
                            if storeManager.isSubscribed {
                                restoreMessage = "Your subscription has been restored!"
                            } else {
                                restoreMessage = "No subscription found to restore."
                            }
                            showingRestoreAlert = true
                        }
                    }) {
                        if isRestoringPurchases {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Restore Purchases")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                        }
                    }
                    .disabled(isRestoringPurchases)
                }
            }
            
            // MARK: - About Section
            Section(header: Text("ABOUT")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms of Service")
                }
            }
            
            // MARK: - Feedback Section
            Section {
                Button(action: {
                    // Send feedback action
                    if let url = URL(string: "mailto:support@yourdomain.com?subject=Speech%20Therapy%20App%20Feedback") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Send Feedback")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            Task {
                await storeManager.loadProducts()
            }
        }
        .alert(isPresented: $showingRestoreAlert) {
            Alert(
                title: Text("Restore Purchases"),
                message: Text(restoreMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        Button(action: {
            if let product = storeManager.monthlySubscriptionProduct() {
                Task {
                    do {
                        try await storeManager.purchase(product)
                    } catch {
                        print("Failed to purchase: \(error)")
                    }
                }
            }
        }) {
            if storeManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            } else {
                Text("Subscribe Now")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .disabled(storeManager.isLoading || storeManager.monthlySubscriptionProduct() == nil)
    }
}

// MARK: - Helper Views
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text("Last updated: May 11, 2025")
                    .foregroundColor(.secondary)
                
                // Privacy policy content would go here
                Text("This is where your privacy policy content would go. Include information about data collection, usage, storage, and user rights.")
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text("Last updated: May 11, 2025")
                    .foregroundColor(.secondary)
                
                // Terms of service content would go here
                Text("This is where your terms of service content would go. Include information about acceptable use, subscription terms, refunds, and other legal requirements.")
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(UserPreferences())
        }
    }
}

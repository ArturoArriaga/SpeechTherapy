// PhonemeCardLink.swift
import SwiftUI

struct PhonemeCardLink: View {
    let phoneme: Phoneme
    let isUnlocked: Bool
    @Binding var showAlert: Bool
    @State var navigateToSubscription = false  // Made internal (not private) so extension can access it
    
    var body: some View {
        Group {
            if isUnlocked {
                NavigationLink(destination: PhonemeDetailView(phoneme: phoneme)) {
                    PhonemeCard(phoneme: phoneme, isUnlocked: true)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button {
                    showAlert = true
                } label: {
                    PhonemeCard(phoneme: phoneme, isUnlocked: false)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            NavigationLink(destination: SubscriptionView(), isActive: $navigateToSubscription) {
                EmptyView()
            }
        )
    }
}

// Extension with access to navigateToSubscription
extension PhonemeCardLink {
    // Function to show subscription alert with customized message
    func showSubscriptionAlert() -> Alert {
        Alert(
            title: Text("Premium Feature"),
            message: Text("This phoneme requires a subscription. Unlock all 44 phonemes for $4.99/month."),
            primaryButton: .default(Text("Subscribe")) {
                // Now this will work because navigateToSubscription is not private
                navigateToSubscription = true
            },
            secondaryButton: .cancel(Text("Maybe Later"))
        )
    }
}

// New Subscription View
struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isProcessing = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Unlock All Phonemes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Get access to all 44 phonemes and practice exercises")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Features card
                VStack(alignment: .leading, spacing: 16) {
                    Text("What You'll Get")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    FeatureRow(icon: "checkmark.circle.fill", text: "All 44 phonemes and sound categories")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Consonant blends and diphthongs")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Initial, medial, and final position practice")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Detailed pronunciation guides")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Progress tracking")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Price and Subscribe
                VStack(spacing: 16) {
                    if let product = StoreManager.shared.monthlySubscriptionProduct() {
                        Text("\(product.displayPrice)/month")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Cancel anytime")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button {
                            purchaseSubscription()
                        } label: {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.5))
                                    .cornerRadius(12)
                            } else {
                                Text("Subscribe")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isProcessing)
                        .padding(.top, 8)
                    } else {
                        Text("Loading subscription options...")
                            .foregroundColor(.secondary)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    
                    Button("Restore Purchases") {
                        restorePurchases()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .disabled(isProcessing)
                }
                .padding()
                
                // Legal text
                Text("Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationTitle("Premium Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await StoreManager.shared.loadProducts()
            }
        }
        .alert("Subscription Successful", isPresented: $showingSuccessAlert) {
            Button("Start Using Premium") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You now have access to all phonemes and features. Enjoy your speech therapy practice!")
        }
    }
    
    private func purchaseSubscription() {
        guard let product = StoreManager.shared.monthlySubscriptionProduct() else { return }
        
        isProcessing = true
        
        Task {
            do {
                try await StoreManager.shared.purchase(product)
                isProcessing = false
                
                if StoreManager.shared.isSubscribed {
                    showingSuccessAlert = true
                }
            } catch {
                isProcessing = false
                print("Failed to purchase: \(error)")
            }
        }
    }
    
    private func restorePurchases() {
        isProcessing = true
        
        Task {
            await StoreManager.shared.restorePurchases()
            isProcessing = false
            
            if StoreManager.shared.isSubscribed {
                showingSuccessAlert = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

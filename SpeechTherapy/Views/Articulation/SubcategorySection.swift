import SwiftUI

// MARK: - Updated SubcategorySection with Subscription Alert
struct SubcategorySection: View {
    let title: String
    let items: [Phoneme]
    let userPreferences: UserPreferences
    @State private var showingPremiumAlert = false
    @State private var navigateToSubscription = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(items) { phoneme in
                        PhonemeCardLink(
                            phoneme: phoneme,
                            isUnlocked: userPreferences.isPhonemeUnlocked(symbol: phoneme.symbol),
                            showAlert: $showingPremiumAlert
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(
            NavigationLink(destination: SubscriptionView(), isActive: $navigateToSubscription) {
                EmptyView()
            }
        )
        .alert("Premium Feature", isPresented: $showingPremiumAlert) {
            Button("Subscribe for $4.99/month") {
                navigateToSubscription = true
            }
            Button("Maybe Later", role: .cancel) {}
        } message: {
            Text("This phoneme is only available with a premium subscription. Unlock all 44 phonemes, blends, and practice exercises.")
        }
    }
}

// MARK: - Update ArticulationView Alert
extension ArticulationView {
    var updatedPremiumAlert: Alert {
        Alert(
            title: Text("Premium Feature"),
            message: Text("This phoneme is only available with a premium subscription. Unlock all 44 phonemes, blends, and practice exercises for $4.99/month."),
            primaryButton: .default(Text("Subscribe")) {
                navigateToSettings = true
            },
            secondaryButton: .cancel(Text("Maybe Later"))
        )
    }
}

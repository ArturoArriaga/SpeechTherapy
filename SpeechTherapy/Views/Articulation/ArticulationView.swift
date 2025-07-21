import SwiftUI

// MARK: - Articulation View
struct ArticulationView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)
    ]
    
    // Replace the local phonemes array and computed properties
    private var phonemes: [Phoneme] { PhonemeData.phonemes }
    private var consonantSubcategories: [PhonemeSubcategory] { PhonemeData.getConsonantSubcategories() }
    private var blendSubcategories: [PhonemeSubcategory] { PhonemeData.getBlendSubcategories() }
    
    // Create subcategories for vowels and diphthongs
    private var vowelSubcategory: PhonemeSubcategory {
        return PhonemeSubcategory(name: "Vowels", items: phonemes.filter { $0.category == .vowels })
    }
    
    private var diphthongSubcategory: PhonemeSubcategory {
        return PhonemeSubcategory(name: "Diphthongs", items: phonemes.filter { $0.category == .diphthongs })
    }
    
    @State private var selectedCategory: PhonemeCategory? = nil
    @State private var showingPremiumAlert = false
    @State var navigateToSettings = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    ForEach(PhonemeCategory.allCases, id: \.self) { category in
                        CategoryButton(title: category.rawValue, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if selectedCategory == nil || selectedCategory == .consonants {
                        // Consonants section with subcategories in horizontal scrolling sections
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Consonants")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(consonantSubcategories) { subcategory in
                                SubcategorySection(
                                    title: subcategory.name,
                                    items: subcategory.items,
                                    userPreferences: userPreferences
                                )
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if selectedCategory == nil {
                        // Vowels as horizontal scrolling section when "All" is selected
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vowels")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            SubcategorySection(
                                title: "",
                                items: vowelSubcategory.items,
                                userPreferences: userPreferences
                            )
                        }
                        .padding(.bottom, 16)
                        
                        // Diphthongs as horizontal scrolling section when "All" is selected
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Diphthongs")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            SubcategorySection(
                                title: "",
                                items: diphthongSubcategory.items,
                                userPreferences: userPreferences
                            )
                        }
                        .padding(.bottom, 16)
                    } else if selectedCategory == .vowels {
                        // Vowels as a grid when "Vowels" category is selected
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vowels")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(phonemes.filter { $0.category == .vowels }) { phoneme in
                                    PhonemeCardLink(
                                        phoneme: phoneme,
                                        isUnlocked: userPreferences.isPhonemeUnlocked(symbol: phoneme.symbol),
                                        showAlert: $showingPremiumAlert
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 16)
                    } else if selectedCategory == .diphthongs {
                        // Diphthongs as a grid when "Diphthongs" category is selected
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Diphthongs")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(phonemes.filter { $0.category == .diphthongs }) { phoneme in
                                    PhonemeCardLink(
                                        phoneme: phoneme,
                                        isUnlocked: userPreferences.isPhonemeUnlocked(symbol: phoneme.symbol),
                                        showAlert: $showingPremiumAlert
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if selectedCategory == nil || selectedCategory == .blends {
                        // Blends section with subcategories in horizontal scrolling sections
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Blends")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(blendSubcategories) { subcategory in
                                SubcategorySection(
                                    title: subcategory.name,
                                    items: subcategory.items,
                                    userPreferences: userPreferences
                                )
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(
            NavigationLink(destination: SettingsView(), isActive: $navigateToSettings) {
                EmptyView()
            }
        )
        .alert("Unlock All Phonemes", isPresented: $showingPremiumAlert) {
            Button("Go to Settings") {
                navigateToSettings = true
            }
            Button("Maybe Later", role: .cancel) {}
        } message: {
            Text("Unlock all phonemes in the Settings tab to access this feature.")
        }
    }
}

// MARK: - Preview
struct ArticulationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArticulationView()
                .environmentObject(UserPreferences())
                .navigationTitle("Articulation")
        }
    }
}

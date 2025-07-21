//
//  PhonemeDetailView.swift
//  SpeechTherapy
//
//  Updated for SpeechTherapy app on 5/11/25.
//

import SwiftUI

struct PhonemeDetailView: View {
    let phoneme: Phoneme
    
    // Practice configuration state
    @State private var practicePlan: PracticePlan
    @State private var navigateToPractice = false
    
    // Initialize with defaults
    init(phoneme: Phoneme) {
        self.phoneme = phoneme
        
        // Set up initial practice plan
        let initialPosition: PhonemePosition = .initial
        _practicePlan = State(initialValue: PracticePlan(
            phoneme: phoneme,
            selectedPositions: [initialPosition],
            level: .words,
            selectedWords: []
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // Phoneme symbol and name
                VStack(spacing: 8) {
                    Text(phoneme.symbol)
                        .font(.system(size: 64, weight: .bold))
                    
                    Text(phoneme.name)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Practice configuration section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Practice Configuration")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Position Selector
                    MultiSelectHorizontalSelector(
                        title: "Position",
                        items: PhonemePosition.allCases.map { $0 },
                        selection: $practicePlan.selectedPositions
                    )
                    .padding(.bottom, 8)
                    
                    // Level Selector
                    HorizontalSelector(
                        title: "Level",
                        items: PhonemeLevel.allCases.map { $0 },
                        selection: $practicePlan.level
                    )
                    .padding(.bottom, 8)
                    
                    // Target Words Selector
                    WordSelectorSection(
                        title: "Target Words",
                        practicePlan: $practicePlan
                    )
                    .padding(.bottom, 8)
                    
                    // Start Practice Button
                    Button(action: {
                        loadPracticeWords()
                        navigateToPractice = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.largeTitle)
                            Text("Start Practice")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(!practicePlan.hasSelectedWords)
                    .opacity(practicePlan.hasSelectedWords ? 1.0 : 0.6)
                }
                .padding(.bottom)
                
                // Practice words list (could be removed or kept as reference)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Practice Words")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // This would be populated with real practice words for each phoneme
                    ForEach(getSamplePracticeWords(for: phoneme), id: \.self) { word in
                        Text("• \(word)")
                            .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .navigationTitle("\(phoneme.symbol) Sound")
        .onAppear {
            // Load practice words when view appears
            loadPracticeWords()
        }
        .background(
            NavigationLink(destination:
                           PracticeCardsView(practicePlan: practicePlan),
                           isActive: $navigateToPractice) {
                EmptyView()
            }
        )
    }
    
    // Load practice words based on selected positions
    private func loadPracticeWords() {
        let words = PracticeDataProvider.getWords(for: phoneme,
                                                 positions: practicePlan.selectedPositions)
        practicePlan.selectedWords = words
    }
    
    // Sample practice words - in a real app, you'd have a more comprehensive database
    private func getSamplePracticeWords(for phoneme: Phoneme) -> [String] {
        switch phoneme.symbol {
        case "/p/":
            return ["pat", "pen", "pear", "pie", "pot", "pop", "paper"]
        case "/b/":
            return ["bat", "bed", "bear", "bike", "boy", "bubble", "baby"]
        case "/t/":
            return ["top", "ten", "toe", "tiger", "tall", "time", "table"]
        case "/d/":
            return ["dog", "dad", "door", "dish", "day", "down", "dice"]
        case "/k/":
            return ["cat", "cup", "kite", "key", "cake", "can", "ketchup"]
        case "/tʃ/":
            return ["chip", "chair", "cheese", "church", "chicken", "match", "watch"]
        // Add more cases for other phonemes
        default:
            return [phoneme.example, "More practice words would be added here"]
        }
    }
}

#if DEBUG
struct PhonemeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhonemeDetailView(
                phoneme: Phoneme(
                    symbol: "/tʃ/",
                    name: "Ch Sound",
                    example: "chip",
                    category: .consonants,
                    subcategory: "Affricates",
                    language: .english
                )
            )
        }
    }
}
#endif

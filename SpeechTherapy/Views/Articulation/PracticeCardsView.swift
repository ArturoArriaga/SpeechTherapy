//
//  PracticeCardsView.swift
//  SpeechTherapy
//
//  Updated for SpeechTherapy app on 5/11/25.
//

import SwiftUI

struct PracticeCardsView: View {
    let practicePlan: PracticePlan
    
    @State private var practiceWords: [PracticeWord] = []
    @State private var currentIndex = 0
    @State private var showingCompletionAlert = false
    @State private var responses: [Bool?] = [] // nil = skipped, true = correct, false = incorrect
    
    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                Text("\(currentIndex + 1)/\(practiceWords.count)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Done") {
                    showingCompletionAlert = true
                }
                .fontWeight(.semibold)
            }
            .padding()
            
            Spacer()
            
            // Practice card
            if !practiceWords.isEmpty {
                VStack(spacing: 24) {
                    // Phoneme header
                    Text(practicePlan.phoneme.symbol)
                        .font(.system(size: 56, weight: .bold))
                        .padding(.bottom, 12)
                    
                    // Image placeholder (added as requested)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 180)
                        .overlay(
                            Text("Image Placeholder")
                                .foregroundColor(.blue)
                        )
                        .padding(.horizontal)
                    
                    // Practice word card
                    PracticeWordCard(
                        word: practiceWords[currentIndex].forLevel(practicePlan.level),
                        level: practicePlan.level
                    )
                    
                    // Level information
                    Text(practicePlan.level.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 40) {
                        // Correct button
                        Button {
                            recordResponse(true)
                            nextCard()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Neutral button (skip)
                        Button {
                            recordResponse(nil)
                            nextCard()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "equal")
                                    .font(.title)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Incorrect button
                        Button {
                            recordResponse(false)
                            nextCard()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    // Record button
                    Button {
                        // Record functionality would go here
                    } label: {
                        HStack {
                            Image(systemName: "mic.circle.fill")
                            Text("Record")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            } else {
                // Handle the case where there are no practice words
                VStack(spacing: 16) {
                    Text("No practice words selected")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Please go back and select practice words")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPracticeWords()
        }
        .alert("Practice Complete", isPresented: $showingCompletionAlert) {
            Button("Practice Again") {
                resetPractice()
            }
            Button("Return") {
                // This would pop back to the detail view
                // But in SwiftUI previews we don't have control over navigation stack
            }
        } message: {
            Text(practiceCompletionMessage)
        }
    }
    
    private var navigationTitle: String {
        let positions = practicePlan.selectedPositions.map { $0.rawValue }.joined(separator: ", ")
        return "\(practicePlan.phoneme.symbol) - \(positions)"
    }
    
    private var practiceCompletionMessage: String {
        let correct = responses.filter { $0 == true }.count
        let total = responses.count
        let percentage = total > 0 ? Int((Double(correct) / Double(total)) * 100) : 0
        
        return "Great job practicing the \(practicePlan.phoneme.symbol) sound!\n\nYou got \(correct) out of \(total) correct (\(percentage)%)."
    }
    
    private func loadPracticeWords() {
        // Get only the selected words for practice
        practiceWords = practicePlan.getPracticeWordsForSession()
        
        // Reset responses array
        responses = Array(repeating: nil, count: practiceWords.count)
    }
    
    private func recordResponse(_ correct: Bool?) {
        if currentIndex < responses.count {
            responses[currentIndex] = correct
        }
    }
    
    private func nextCard() {
        if currentIndex < practiceWords.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            showingCompletionAlert = true
        }
    }
    
    private func resetPractice() {
        currentIndex = 0
        responses = Array(repeating: nil, count: practiceWords.count)
    }
}

//struct PracticeWordCard: View {
//    let word: String
//    let level: PhonemeLevel
//    
//    var body: some View {
//        VStack {
//            Text(word)
//                .font(.system(size: getFontSize(for: level), weight: .semibold))
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color.white)
//                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
//                )
//                .padding(.horizontal)
//        }
//    }
//    
//    // Adjust font size based on level (longer text for sentences needs smaller font)
//    private func getFontSize(for level: PhonemeLevel) -> CGFloat {
//        switch level {
//        case .isolation, .syllable:
//            return 60
//        case .words:
//            return 48
//        case .phrases:
//            return 36
//        case .sentences:
//            return 28
//        }
//    }
//}

#if DEBUG
struct PracticeCardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let phoneme = Phoneme(
                symbol: "/tʃ/",
                name: "Ch Sound",
                example: "chip",
                category: .consonants,
                subcategory: "Affricates",
                language: .english
            )
            
            let words = [
                PracticeWord(word: "chip", phonemeIndex: 0, position: .initial, isSelected: true),
                PracticeWord(word: "chair", phonemeIndex: 0, position: .initial, isSelected: true),
                PracticeWord(word: "teacher", phonemeIndex: 3, position: .medial, isSelected: true)
            ]
            
            let practicePlan = PracticePlan(
                phoneme: phoneme,
                selectedPositions: [.initial, .medial],
                level: .words,
                selectedWords: words
            )
            
            PracticeCardsView(practicePlan: practicePlan)
        }
    }
}
#endif

//
//  PhonemePositionSelectorView.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/10/25.
//

import SwiftUI

//
//  PhonemePositionSelectorView.swift
//  SpeechTherapy
//
//  Created on 5/10/25.
//

import SwiftUI

enum PhonemePosition: String, CaseIterable, Identifiable {
    case initial = "Initial"
    case medial = "Medial"
    case final = "Final"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .initial:
            return "Beginning of words"
        case .medial:
            return "Middle of words"
        case .final:
            return "End of words"
        }
    }
    
    var examples: String {
        switch self {
        case .initial:
            return "e.g., pat, pen, pie"
        case .medial:
            return "e.g., happy,erapid, cupon"
        case .final:
            return "e.g., mop, help, cup"
        }
    }
}


struct PhonemePositionSelectorView: View {
    let phoneme: Phoneme
    @State private var practicePlan: PracticePlan
    
    // Initialize with default practice plan
    init(phoneme: Phoneme) {
        self.phoneme = phoneme
        
        // Create initial practice plan with default position
        let initialPosition: PhonemePosition = .initial
        _practicePlan = State(initialValue: PracticePlan(
            phoneme: phoneme,
            selectedPositions: [initialPosition],
            level: .words,
            selectedWords: []
        ))
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            // Header with phoneme
            VStack(spacing: 8) {
                Text(phoneme.symbol)
                    .font(.system(size: 64, weight: .bold))
                
                Text("Select practice position")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.top)
            
            // Position options
            VStack(spacing: 16) {
                ForEach(PhonemePosition.allCases) { position in
                    NavigationLink(destination: PracticeCardsView(practicePlan: createPracticePlan(for: position))) {
                        PositionOptionCard(position: position)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("\(phoneme.symbol) Position")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper to create a practice plan for a specific position
    private func createPracticePlan(for position: PhonemePosition) -> PracticePlan {
        var plan = PracticePlan(
            phoneme: phoneme,
            selectedPositions: [position],
            level: .words,
            selectedWords: []
        )
        
        // Load practice words for this position
        plan.selectedWords = PracticeDataProvider.getWords(
            for: phoneme,
            positions: [position]
        )
        
        return plan
    }
}

struct PositionOptionCard: View {
    let position: PhonemePosition
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(position.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(position.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(position.examples)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct PhonemePositionSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PhonemePositionSelectorView(
                phoneme: Phoneme(
                    symbol: "/p/",
                    name: "Voiceless Bilabial Stop",
                    example: "pat",
                    category: .consonants,
                    subcategory: "Stops",
                    language: .english
                )
            )
        }
    }
}

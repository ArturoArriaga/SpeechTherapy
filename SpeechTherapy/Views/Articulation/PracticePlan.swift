//
//  PracticePlan.swift
//  SpeechTherapy
//
//  Created for SpeechTherapy app on 5/11/25.
//

import Foundation

struct PracticePlan {
    let phoneme: Phoneme
    var selectedPositions: Set<PhonemePosition> = []
    var level: PhonemeLevel = .words
    var selectedWords: [PracticeWord] = []
    
    var allWordsSelected: Bool {
        !selectedWords.isEmpty && selectedWords.allSatisfy { $0.isSelected }
    }
    
    var hasSelectedWords: Bool {
        selectedWords.contains { $0.isSelected }
    }
    
    var selectedWordCount: Int {
        selectedWords.filter { $0.isSelected }.count
    }
    
    mutating func toggleAllWords(selected: Bool) {
        for i in 0..<selectedWords.count {
            selectedWords[i].isSelected = selected
        }
    }
    
    mutating func toggleWordSelection(at index: Int) {
        if index >= 0 && index < selectedWords.count {
            selectedWords[index].isSelected.toggle()
        }
    }
    
    // Helper method to get the actual practice words for the session
    // based on selected words and configuration
    func getPracticeWordsForSession() -> [PracticeWord] {
        // Filter only selected words
        return selectedWords.filter { $0.isSelected }
    }
}

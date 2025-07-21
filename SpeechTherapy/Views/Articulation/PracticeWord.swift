//
//  PracticeWord.swift
//  SpeechTherapy
//
//  Created for SpeechTherapy app on 5/11/25.
//

import Foundation

// Updated version of PracticeWord with isSelected property
struct PracticeWord: Identifiable {
    let id = UUID()
    let word: String
    let phonemeIndex: Int // Position of the phoneme in the word
    let position: PhonemePosition // Position of the phoneme in the word
    var isSelected: Bool = true // Default to selected
    
    // Helper to create a level-specific representation of the word
    func forLevel(_ level: PhonemeLevel) -> String {
        switch level {
        case .isolation:
            // Just the phoneme sound
            return word.count > phonemeIndex ? String(word[word.index(word.startIndex, offsetBy: phonemeIndex)]) : word
        case .syllable:
            // Create a simple syllable using the phoneme
            if position == .initial {
                return word.prefix(2).lowercased()
            } else if position == .final {
                return word.suffix(2).lowercased()
            } else {
                // For medial, take surrounding characters
                let start = max(0, phonemeIndex - 1)
                let end = min(word.count, phonemeIndex + 2)
                let startIndex = word.index(word.startIndex, offsetBy: start)
                let endIndex = word.index(word.startIndex, offsetBy: end)
                return String(word[startIndex..<endIndex]).lowercased()
            }
        case .words:
            // Just the word itself
            return word
        case .phrases:
            // Create a simple phrase using the word
            return generatePhrase(for: word)
        case .sentences:
            // Create a simple sentence using the word
            return generateSentence(for: word)
        }
    }
    
    // Helper to generate a simple phrase for a word
    private func generatePhrase(for word: String) -> String {
        let prefixes = ["the big", "my little", "a nice", "two red", "some blue"]
        return "\(prefixes.randomElement() ?? "the") \(word)"
    }
    
    // Helper to generate a simple sentence for a word
    private func generateSentence(for word: String) -> String {
        let templates = [
            "I see the $.",
            "Look at the $.",
            "The $ is nice.",
            "We have a $.",
            "Can you find the $?"
        ]
        let template = templates.randomElement() ?? "I like the $."
        return template.replacingOccurrences(of: "$", with: word)
    }
}

// Mock data generator for practice words
struct PracticeDataProvider {
    static func getWords(for phoneme: Phoneme, positions: Set<PhonemePosition>) -> [PracticeWord] {
        var allWords: [PracticeWord] = []
        
        // If no positions specified, default to all positions
        let positionsToUse = positions.isEmpty ? Set(PhonemePosition.allCases) : positions
        
        for position in positionsToUse {
            let wordsForPosition = getWordsForPosition(phoneme: phoneme, position: position)
            allWords.append(contentsOf: wordsForPosition)
        }
        
        return allWords
    }
    
    private static func getWordsForPosition(phoneme: Phoneme, position: PhonemePosition) -> [PracticeWord] {
        // In a real app, this would come from a database or API
        // Here we're using mock data
        switch phoneme.symbol {
        case "/p/":
            switch position {
            case .initial:
                return [
                    PracticeWord(word: "pat", phonemeIndex: 0, position: position),
                    PracticeWord(word: "pen", phonemeIndex: 0, position: position),
                    PracticeWord(word: "pie", phonemeIndex: 0, position: position),
                    PracticeWord(word: "park", phonemeIndex: 0, position: position),
                    PracticeWord(word: "push", phonemeIndex: 0, position: position)
                ]
            case .medial:
                return [
                    PracticeWord(word: "happy", phonemeIndex: 2, position: position),
                    PracticeWord(word: "apple", phonemeIndex: 1, position: position),
                    PracticeWord(word: "happen", phonemeIndex: 2, position: position),
                    PracticeWord(word: "zipper", phonemeIndex: 2, position: position),
                    PracticeWord(word: "cupcake", phonemeIndex: 2, position: position)
                ]
            case .final:
                return [
                    PracticeWord(word: "top", phonemeIndex: 2, position: position),
                    PracticeWord(word: "help", phonemeIndex: 3, position: position),
                    PracticeWord(word: "cup", phonemeIndex: 2, position: position),
                    PracticeWord(word: "soap", phonemeIndex: 3, position: position),
                    PracticeWord(word: "mop", phonemeIndex: 2, position: position)
                ]
            }
        case "/tʃ/": // Ch sound as in the provided image
            switch position {
            case .initial:
                return [
                    PracticeWord(word: "chip", phonemeIndex: 0, position: position),
                    PracticeWord(word: "chair", phonemeIndex: 0, position: position),
                    PracticeWord(word: "chin", phonemeIndex: 0, position: position),
                    PracticeWord(word: "cheese", phonemeIndex: 0, position: position),
                    PracticeWord(word: "cherry", phonemeIndex: 0, position: position)
                ]
            case .medial:
                return [
                    PracticeWord(word: "teacher", phonemeIndex: 3, position: position),
                    PracticeWord(word: "feature", phonemeIndex: 3, position: position),
                    PracticeWord(word: "fortune", phonemeIndex: 3, position: position),
                    PracticeWord(word: "nature", phonemeIndex: 2, position: position),
                    PracticeWord(word: "picture", phonemeIndex: 3, position: position)
                ]
            case .final:
                return [
                    PracticeWord(word: "match", phonemeIndex: 3, position: position),
                    PracticeWord(word: "watch", phonemeIndex: 3, position: position),
                    PracticeWord(word: "teach", phonemeIndex: 3, position: position),
                    PracticeWord(word: "reach", phonemeIndex: 3, position: position),
                    PracticeWord(word: "beach", phonemeIndex: 3, position: position)
                ]
            }
        default:
            // Generic practice words for all other phonemes
            switch position {
            case .initial:
                return [
                    PracticeWord(word: "Example word 1", phonemeIndex: 0, position: position),
                    PracticeWord(word: "Example word 2", phonemeIndex: 0, position: position),
                    PracticeWord(word: "Example word 3", phonemeIndex: 0, position: position),
                    PracticeWord(word: "Example word 4", phonemeIndex: 0, position: position),
                    PracticeWord(word: "Example word 5", phonemeIndex: 0, position: position)
                ]
            case .medial:
                return [
                    PracticeWord(word: "Example word 1", phonemeIndex: 3, position: position),
                    PracticeWord(word: "Example word 2", phonemeIndex: 4, position: position),
                    PracticeWord(word: "Example word 3", phonemeIndex: 3, position: position),
                    PracticeWord(word: "Example word 4", phonemeIndex: 4, position: position),
                    PracticeWord(word: "Example word 5", phonemeIndex: 3, position: position)
                ]
            case .final:
                return [
                    PracticeWord(word: "Example word 1", phonemeIndex: 7, position: position),
                    PracticeWord(word: "Example word 2", phonemeIndex: 8, position: position),
                    PracticeWord(word: "Example word 3", phonemeIndex: 7, position: position),
                    PracticeWord(word: "Example word 4", phonemeIndex: 8, position: position),
                    PracticeWord(word: "Example word 5", phonemeIndex: 7, position: position)
                ]
            }
        }
    }
}

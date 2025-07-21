//
//  ProgressTrend.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import Foundation
import CoreData

// MARK: - PracticeList Extensions
extension PracticeList {
    var configurationArray: [PracticeConfiguration] {
        let set = configurations as? Set<PracticeConfiguration> ?? []
        return set.sorted {
            $0.phonemeSymbol ?? "" < $1.phonemeSymbol ?? ""
        }
    }
    
    var sessionArray: [PracticeSession] {
        let set = sessions as? Set<PracticeSession> ?? []
        return set.sorted {
            $0.date ?? Date() > $1.date ?? Date()
        }
    }
    
    // Calculate total words in this practice list
    var totalWordCount: Int {
        var uniqueWords = Set<String>()
        
        if let configurations = configurations as? Set<PracticeConfiguration> {
            for config in configurations {
                if let words = config.selectedWords as? Set<PracticeWord> {
                    for word in words {
                        uniqueWords.insert(word.word ?? "")
                    }
                }
            }
        }
        
        return uniqueWords.count
    }
    
    // Get the most recent session (if any)
    var mostRecentSession: PracticeSession? {
        return sessionArray.first
    }
    
    // Calculate progress trend (positive, negative, neutral)
    var progressTrend: ProgressTrend {
        guard sessionArray.count >= 2 else { return .neutral }
        
        let latestSession = sessionArray[0]
        let previousSession = sessionArray[1]
        
        let latestAccuracy = Double(latestSession.correctCount) / Double(latestSession.totalWords)
        let previousAccuracy = Double(previousSession.correctCount) / Double(previousSession.totalWords)
        
        if latestAccuracy > previousAccuracy + 0.05 {
            return .positive
        } else if latestAccuracy < previousAccuracy - 0.05 {
            return .negative
        } else {
            return .neutral
        }
    }
}

// MARK: - PracticeConfiguration Extensions
extension PracticeConfiguration {
    var selectedWordArray: [PracticeWord] {
        let set = selectedWords as? Set<PracticeWord> ?? []
        return set.sorted {
            $0.word ?? "" < $1.word ?? ""
        }
    }
    
    // Format position for display
    var positionFormatted: String {
        switch position {
        case "initial": return "Initial"
        case "medial": return "Medial"
        case "final": return "Final"
        default: return position ?? "Unknown"
        }
    }
    
    // Format level for display
    var levelFormatted: String {
        switch level {
        case "isolation": return "Isolation"
        case "syllable": return "Syllable"
        case "words": return "Words"
        case "phrases": return "Phrases"
        case "sentences": return "Sentences"
        default: return level ?? "Unknown"
        }
    }
    
    // Get a summary of this configuration
    var summary: String {
        return "\(phonemeSymbol ?? "") - \(positionFormatted) (\(levelFormatted))"
    }
}

// MARK: - PracticeSession Extensions
extension PracticeSession {
    var configurationResultArray: [ConfigurationResult] {
        let set = configurationResults as? Set<ConfigurationResult> ?? []
        return set.sorted {
            $0.phonemeSymbol ?? "" < $1.phonemeSymbol ?? ""
        }
    }
    
    // Calculate accuracy percentage
    var accuracyPercentage: Int {
        guard totalWords > 0 else { return 0 }
        let percentage = (Double(correctCount) / Double(totalWords)) * 100.0
        return Int(percentage)
    }
    
    // Format the date for display
    var formattedDate: String {
        guard let date = date else { return "Unknown Date" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
}

// MARK: - Enums for State Management
enum ProgressTrend {
    case positive
    case negative
    case neutral
    
    var icon: String {
        switch self {
        case .positive: return "arrow.up.circle.fill"
        case .negative: return "arrow.down.circle.fill"
        case .neutral: return "equal.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .positive: return "green"
        case .negative: return "red"
        case .neutral: return "gray"
        }
    }
}
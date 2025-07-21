//
//  PhonemeLevel.swift
//  SpeechTherapy
//
//  Created for SpeechTherapy app on 5/11/25.
//

import Foundation

enum PhonemeLevel: String, CaseIterable, Identifiable {
    case isolation = "Isolation"
    case syllable = "Syllable"
    case words = "Words"
    case phrases = "Phrases"
    case sentences = "Sentences"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .isolation:
            return "Practice the sound by itself"
        case .syllable:
            return "Practice in simple syllables"
        case .words:
            return "Practice in single words"
        case .phrases:
            return "Practice in short phrases"
        case .sentences:
            return "Practice in complete sentences"
        }
    }
    
    var examples: String {
        switch self {
        case .isolation:
            return "e.g., /s/, /t/, /k/"
        case .syllable:
            return "e.g., sa, si, so, su"
        case .words:
            return "e.g., sun, sock, say"
        case .phrases:
            return "e.g., sunny day, six socks"
        case .sentences:
            return "e.g., Sam sees six seals."
        }
    }
}

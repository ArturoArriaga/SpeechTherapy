//
//  Phoneme.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/10/25.
//

import SwiftUI

struct Phoneme: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let example: String
    let category: PhonemeCategory
    let subcategory: String
    let language: PhonemeLanguage
}

enum PhonemeCategory: String, CaseIterable {
    case consonants = "Consonants"
    case vowels = "Vowels"
    case blends = "Blends"
    case diphthongs = "Diphthongs"
}

// For subgrouping consonants and blends
struct PhonemeSubcategory: Identifiable {
    let id = UUID()
    let name: String
    let items: [Phoneme]
}

enum PhonemeLanguage {
    case english
    case spanish
}

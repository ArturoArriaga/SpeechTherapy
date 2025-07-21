
//
//  PhonemeData.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/10/25.
//

import SwiftUI

// This struct will hold the static data
struct PhonemeData {
    // Make this static so it can be accessed without creating an instance
    static let phonemes: [Phoneme] = [
        // Consonants - Stops
        Phoneme(symbol: "/p/", name: "P", example: "pat", category: .consonants, subcategory: "Stops", language: .english),
        Phoneme(symbol: "/b/", name: "B", example: "bat", category: .consonants, subcategory: "Stops", language: .english),
        Phoneme(symbol: "/t/", name: "T", example: "top", category: .consonants, subcategory: "Stops", language: .english),
        Phoneme(symbol: "/d/", name: "D", example: "dog", category: .consonants, subcategory: "Stops", language: .english),
        Phoneme(symbol: "/k/", name: "K", example: "cat", category: .consonants, subcategory: "Stops", language: .english),
        Phoneme(symbol: "/g/", name: "G", example: "get", category: .consonants, subcategory: "Stops", language: .english),
        
        // Consonants - Fricatives
        Phoneme(symbol: "/f/", name: "F", example: "fan", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/v/", name: "V", example: "van", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/θ/", name: "Theta", example: "thin", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/ð/", name: "Eth", example: "this", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/s/", name: "S", example: "sit", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/z/", name: "Z", example: "zip", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/ʃ/", name: "Sh", example: "ship", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/ʒ/", name: "Zh", example: "measure", category: .consonants, subcategory: "Fricatives", language: .english),
        Phoneme(symbol: "/h/", name: "H", example: "hat", category: .consonants, subcategory: "Fricatives", language: .english),
        
        // Consonants - Affricates
        Phoneme(symbol: "/tʃ/", name: "Ch", example: "chip", category: .consonants, subcategory: "Affricates", language: .english),
        Phoneme(symbol: "/dʒ/", name: "J", example: "jump", category: .consonants, subcategory: "Affricates", language: .english),
        
        // Consonants - Nasals
        Phoneme(symbol: "/m/", name: "M", example: "man", category: .consonants, subcategory: "Nasals", language: .english),
        Phoneme(symbol: "/n/", name: "N", example: "no", category: .consonants, subcategory: "Nasals", language: .english),
        Phoneme(symbol: "/ŋ/", name: "Ng", example: "sing", category: .consonants, subcategory: "Nasals", language: .english),
        
        // Consonants - Approximants
        Phoneme(symbol: "/l/", name: "L", example: "leg", category: .consonants, subcategory: "Approximants", language: .english),
        Phoneme(symbol: "/ɹ/", name: "R", example: "run", category: .consonants, subcategory: "Approximants", language: .english),
        Phoneme(symbol: "/j/", name: "Y", example: "yes", category: .consonants, subcategory: "Approximants", language: .english),
        Phoneme(symbol: "/w/", name: "W", example: "wet", category: .consonants, subcategory: "Approximants", language: .english),
        
        // Vowels
        Phoneme(symbol: "/i/", name: "I", example: "see", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ɪ/", name: "I", example: "sit", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/e/", name: "E", example: "may", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ɛ/", name: "E", example: "bed", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/æ/", name: "A", example: "cat", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ɑ/", name: "A", example: "father", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ɔ/", name: "O", example: "thought", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/o/", name: "O", example: "go", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ʊ/", name: "U - Hook", example: "put", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/u/", name: "U", example: "boot", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ʌ/", name: "Uh", example: "but", category: .vowels, subcategory: "Vowels", language: .english),
        Phoneme(symbol: "/ə/", name: "Schwa", example: "about", category: .vowels, subcategory: "Vowels", language: .english),
        
        // Diphthongs
        Phoneme(symbol: "/eɪ/", name: "A", example: "face", category: .diphthongs, subcategory: "Diphthongs", language: .english),
        Phoneme(symbol: "/aɪ/", name: "I", example: "price", category: .diphthongs, subcategory: "Diphthongs", language: .english),
        Phoneme(symbol: "/ɔɪ/", name: "Oi", example: "choice", category: .diphthongs, subcategory: "Diphthongs", language: .english),
        Phoneme(symbol: "/aʊ/", name: "Ow", example: "mouth", category: .diphthongs, subcategory: "Diphthongs", language: .english),
        Phoneme(symbol: "/oʊ/", name: "O", example: "goat", category: .diphthongs, subcategory: "Diphthongs", language: .english),
        
        // Blends - L Blends
        Phoneme(symbol: "/bl/", name: "B L", example: "blue", category: .blends, subcategory: "L-Blends", language: .english),
        Phoneme(symbol: "/fl/", name: "F L", example: "fly", category: .blends, subcategory: "L-Blends", language: .english),
        Phoneme(symbol: "/gl/", name: "G L", example: "glass", category: .blends, subcategory: "L-Blends", language: .english),
        Phoneme(symbol: "/kl/", name: "K L", example: "clean", category: .blends, subcategory: "L-Blends", language: .english),
        Phoneme(symbol: "/pl/", name: "P L", example: "play", category: .blends, subcategory: "L-Blends", language: .english),
        Phoneme(symbol: "/sl/", name: "S L", example: "slide", category: .blends, subcategory: "L-Blends", language: .english),
        
        // Blends - R Blends
        Phoneme(symbol: "/br/", name: "B R", example: "brown", category: .blends, subcategory: "R-Blends", language: .english),
        Phoneme(symbol: "/dr/", name: "D R", example: "drive", category: .blends, subcategory: "R-Blends", language: .english),
        Phoneme(symbol: "/fr/", name: "F R", example: "frog", category: .blends, subcategory: "R-Blends", language: .english),
        Phoneme(symbol: "/gr/", name: "G R", example: "green", category: .blends, subcategory: "R-Blends", language: .english),
        Phoneme(symbol: "/kr/", name: "K R", example: "crab", category: .blends, subcategory: "R-Blends", language: .english),
        Phoneme(symbol: "/pr/", name: "P R", example: "price", category: .blends, subcategory: "R-Blends", language: .english),
        Phoneme(symbol: "/tr/", name: "T R", example: "train", category: .blends, subcategory: "R-Blends", language: .english),
        
        // Blends - S Blends
        Phoneme(symbol: "/sk/", name: "S K", example: "sky", category: .blends, subcategory: "S-Blends", language: .english),
        Phoneme(symbol: "/sm/", name: "S M", example: "small", category: .blends, subcategory: "S-Blends", language: .english),
        Phoneme(symbol: "/sn/", name: "S N", example: "snake", category: .blends, subcategory: "S-Blends", language: .english),
        Phoneme(symbol: "/sp/", name: "S P", example: "spoon", category: .blends, subcategory: "S-Blends", language: .english),
        Phoneme(symbol: "/st/", name: "S T", example: "star", category: .blends, subcategory: "S-Blends", language: .english),
        Phoneme(symbol: "/sw/", name: "S W", example: "swim", category: .blends, subcategory: "S-Blends", language: .english),
        
        // Spanish-specific phonemes
        Phoneme(symbol: "/ɾ/", name: "Tap R", example: "pero", category: .consonants, subcategory: "Taps", language: .spanish),
        Phoneme(symbol: "/r/", name: "Trill R", example: "perro", category: .consonants, subcategory: "Trills", language: .spanish),
        Phoneme(symbol: "/x/", name: "J", example: "jamón", category: .consonants, subcategory: "Fricatives", language: .spanish),
        Phoneme(symbol: "/ɲ/", name: "Ñ", example: "niño", category: .consonants, subcategory: "Nasals", language: .spanish),
        Phoneme(symbol: "/ʝ/", name: "Yod", example: "yo", category: .consonants, subcategory: "Approximants", language: .spanish),
        Phoneme(symbol: "/tʃ/", name: "Ch", example: "chico", category: .consonants, subcategory: "Affricates", language: .spanish)
    ]
    
    // Add helper methods that can be useful for filtering
    static func getPhonemesForCategory(_ category: PhonemeCategory) -> [Phoneme] {
        return phonemes.filter { $0.category == category }
    }
    
    static func getConsonantSubcategories() -> [PhonemeSubcategory] {
        let consonants = phonemes.filter { $0.category == .consonants }
        let subcategoryNames = Set(consonants.map { $0.subcategory }).sorted()
        
        return subcategoryNames.map { subcategoryName in
            let items = consonants.filter { $0.subcategory == subcategoryName }
            return PhonemeSubcategory(name: subcategoryName, items: items)
        }
    }
    
    static func getBlendSubcategories() -> [PhonemeSubcategory] {
        let blends = phonemes.filter { $0.category == .blends }
        let subcategoryNames = Set(blends.map { $0.subcategory }).sorted()
        
        return subcategoryNames.map { subcategoryName in
            let items = blends.filter { $0.subcategory == subcategoryName }
            return PhonemeSubcategory(name: subcategoryName, items: items)
        }
    }
}

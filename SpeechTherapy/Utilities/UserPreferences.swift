import SwiftUI
import Combine

class UserPreferences: ObservableObject {
    // Published properties
    @Published var completedExercises: Set<String> = []
    @Published var favoritePhonemes: Set<String> = []
    
    // Free phonemes that are available to all users
    private let freePhonemes: Set<String> = ["p", "t", "k"]
    
    // Subscription tracking
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load saved data
        loadPreferences()
        
        // Subscribe to store manager updates to know when subscription status changes
        StoreManager.shared.$isSubscribed
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Phoneme Access
    
    func isPhonemeUnlocked(symbol: String) -> Bool {
        // Always return true for free phonemes
        if freePhonemes.contains(symbol) {
            return true
        }
        
        // Return subscription status for premium phonemes
        return StoreManager.shared.isSubscribed
    }
    
    // MARK: - Exercise Tracking
    
    func markExerciseCompleted(id: String) {
        completedExercises.insert(id)
        savePreferences()
    }
    
    func isExerciseCompleted(id: String) -> Bool {
        return completedExercises.contains(id)
    }
    
    // MARK: - Favorites
    
    func toggleFavorite(phonemeSymbol: String) {
        if favoritePhonemes.contains(phonemeSymbol) {
            favoritePhonemes.remove(phonemeSymbol)
        } else {
            favoritePhonemes.insert(phonemeSymbol)
        }
        savePreferences()
    }
    
    func isFavorite(phonemeSymbol: String) -> Bool {
        return favoritePhonemes.contains(phonemeSymbol)
    }
    
    // MARK: - Persistence
    
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(completedExercises) {
            UserDefaults.standard.set(encoded, forKey: "completedExercises")
        }
        
        if let encoded = try? JSONEncoder().encode(Array(favoritePhonemes)) {
            UserDefaults.standard.set(encoded, forKey: "favoritePhonemes")
        }
    }
    
    private func loadPreferences() {
        if let savedExercises = UserDefaults.standard.data(forKey: "completedExercises"),
           let decodedExercises = try? JSONDecoder().decode(Set<String>.self, from: savedExercises) {
            completedExercises = decodedExercises
        }
        
        if let savedFavorites = UserDefaults.standard.data(forKey: "favoritePhonemes"),
           let decodedFavorites = try? JSONDecoder().decode([String].self, from: savedFavorites) {
            favoritePhonemes = Set(decodedFavorites)
        }
    }
}

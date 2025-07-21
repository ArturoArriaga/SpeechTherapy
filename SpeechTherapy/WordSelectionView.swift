//
//  WordSelectionView.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import SwiftUI
import CoreData

struct WordSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var configuration: PracticeConfiguration
    
    // Available words for this phoneme/position combination
    @State private var availableWords: [PracticeWord] = []
    
    // Selected words in the Core Data context
    @State private var selectedWordIDs: Set<UUID> = []
    
    // Search text
    @State private var searchText = ""
    
    // Filtered words based on search
    private var filteredWords: [PracticeWord] {
        if searchText.isEmpty {
            return availableWords
        } else {
            return availableWords.filter { ($0.word ?? "").lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search words", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            // Phoneme info header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(configuration.phonemeSymbol ?? "")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text(configuration.phonemeName ?? "")
                        .font(.title3)
                    
                    Spacer()
                    
                    Text("\(selectedWordIDs.count) selected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(configuration.positionFormatted)
                        .font(.subheadline)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(configuration.levelFormatted)
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Word selection list
            List {
                Section {
                    // Select/Deselect All button
                    Button {
                        toggleSelectAll()
                    } label: {
                        HStack {
                            Text(allWordsSelected ? "Deselect All" : "Select All")
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Image(systemName: allWordsSelected ? "minus.circle" : "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if filteredWords.isEmpty {
                        Text("No words found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(filteredWords) { word in
                            WordSelectionRow(
                                word: word,
                                isSelected: selectedWordIDs.contains(word.id ?? UUID()),
                                onToggle: { isSelected in
                                    toggleWordSelection(word, isSelected: isSelected)
                                }
                            )
                        }
                    }
                } header: {
                    if !availableWords.isEmpty {
                        Text("AVAILABLE WORDS")
                    }
                } footer: {
                    Text("Select the words you want to include in this practice configuration.")
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Select Words")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveSelections()
                }
            }
        }
        .onAppear {
            loadAvailableWords()
            loadCurrentSelections()
        }
    }
    
    // MARK: - Helper Properties
    
    private var allWordsSelected: Bool {
        !availableWords.isEmpty && selectedWordIDs.count == availableWords.count
    }
    
    // MARK: - Helper Methods
    
    private func loadAvailableWords() {
        let phonemeSymbol = configuration.phonemeSymbol ?? ""
        let position = configuration.position ?? ""
        
        // Get available words from our sample data provider
        // In a real app, this would come from a database or API
        let phoneme = PhonemeData.phonemes.first { $0.symbol == phonemeSymbol }
        let positionEnum = PhonemePosition.allCases.first { $0.rawValue == position }
        
        if let phoneme = phoneme, let positionEnum = positionEnum {
            let practiceWords = PracticeDataProvider.getWords(for: phoneme, positions: [positionEnum])
            
            // Convert to Core Data PracticeWord entities
            for practiceWord in practiceWords {
                let word = PracticeWord(context: viewContext)
                word.id = UUID()
                word.word = practiceWord.word
                word.phonemeIndex = Int16(practiceWord.phonemeIndex)
                availableWords.append(word)
            }
        }
    }
    
    private func loadCurrentSelections() {
        // Get current selections from Core Data
        if let words = configuration.selectedWords as? Set<PracticeWord> {
            selectedWordIDs = Set(words.compactMap { $0.id })
        }
    }
    
    private func toggleWordSelection(_ word: PracticeWord, isSelected: Bool) {
        guard let wordID = word.id else { return }
        
        if isSelected {
            selectedWordIDs.insert(wordID)
        } else {
            selectedWordIDs.remove(wordID)
        }
    }
    
    private func toggleSelectAll() {
        if allWordsSelected {
            // Deselect all
            selectedWordIDs.removeAll()
        } else {
            // Select all
            selectedWordIDs = Set(availableWords.compactMap { $0.id })
        }
    }
    
    private func saveSelections() {
        // Remove all current selections
        if let words = configuration.selectedWords as? Set<PracticeWord> {
            for word in words {
                configuration.removeFromSelectedWords(word)
            }
        }
        
        // Add newly selected words
        for word in availableWords {
            if let wordID = word.id, selectedWordIDs.contains(wordID) {
                configuration.addToSelectedWords(word)
            }
        }
        
        // Save the context
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving word selections: \(error)")
        }
    }
}

// MARK: - Word Selection Row
struct WordSelectionRow: View {
    let word: PracticeWord
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button {
            onToggle(!isSelected)
        } label: {
            HStack {
                Text(word.word ?? "")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
struct WordSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create a sample configuration
        let config = PracticeConfiguration(context: context)
        config.id = UUID()
        config.phonemeSymbol = "/r/"
        config.phonemeName = "R Sound"
        config.position = "initial"
        config.level = "words"
        
        return NavigationStack {
            WordSelectionView(configuration: config)
                .environment(\.managedObjectContext, context)
        }
    }
}
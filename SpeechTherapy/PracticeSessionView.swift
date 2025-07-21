//
//  PracticeSessionView.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import SwiftUI
import CoreData

struct PracticeSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var list: PracticeList
    
    @State private var selectedConfigurations: [PracticeConfiguration] = []
    @State private var currentPracticeWords: [PracticeWord] = []
    @State private var currentIndex = 0
    @State private var responses: [Bool?] = [] // nil = skipped, true = correct, false = incorrect
    @State private var showingCompletionAlert = false
    @State private var navigateToResults = false
    
    // Session configuration
    @State private var isConfiguringSession = true
    @State private var maxWordsPerConfiguration = 5
    
    var body: some View {
        Group {
            if isConfiguringSession {
                sessionConfigurationView
            } else {
                practiceView
            }
        }
        .navigationTitle("Practice Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isConfiguringSession {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .background(
            NavigationLink(destination: SessionResultsView(
                list: list,
                configurations: selectedConfigurations,
                responses: responses,
                practiceWords: currentPracticeWords
            ), isActive: $navigateToResults) {
                EmptyView()
            }
        )
    }
    
    // MARK: - Configuration View
    private var sessionConfigurationView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Configure Practice Session")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose which configurations to practice and how many words per configuration.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Configuration selection
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("SELECT CONFIGURATIONS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ForEach(list.configurationArray) { config in
                        ConfigurationSelectionRow(
                            configuration: config,
                            isSelected: selectedConfigurations.contains(config),
                            onToggle: { isSelected in
                                toggleConfigSelection(config, isSelected: isSelected)
                            }
                        )
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Words per configuration slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WORDS PER CONFIGURATION")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Each configuration will include up to this many words.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("1")
                                .foregroundColor(.secondary)
                            
                            Slider(value: Binding(
                                get: { Double(maxWordsPerConfiguration) },
                                set: { maxWordsPerConfiguration = Int($0) }
                            ), in: 1...10, step: 1)
                            
                            Text("10")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(maxWordsPerConfiguration) words")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            
            // Start practice button
            Button {
                prepareSession()
            } label: {
                Text("Start Practice")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .disabled(selectedConfigurations.isEmpty)
            .opacity(selectedConfigurations.isEmpty ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Practice View
    private var practiceView: some View {
        VStack {
            // Progress indicator
            HStack {
                Text("\(currentIndex + 1)/\(currentPracticeWords.count)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("End Session") {
                    showingCompletionAlert = true
                }
                .fontWeight(.semibold)
            }
            .padding()
            
            Spacer()
            
            // Practice card
            if !currentPracticeWords.isEmpty {
                VStack(spacing: 24) {
                    // Get the configuration for this word
                    let config = getConfigurationForWord(currentPracticeWords[currentIndex])
                    
                    // Phoneme header
                    Text(config?.phonemeSymbol ?? "")
                        .font(.system(size: 56, weight: .bold))
                        .padding(.bottom, 12)
                    
                    // Position and level indicator
                    HStack {
                        Text(config?.positionFormatted ?? "")
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(config?.levelFormatted ?? "")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                    
                    // Image placeholder (you would replace with real image)
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
                        word: currentPracticeWords[currentIndex].word ?? "",
                        level: getLevelForWord(currentPracticeWords[currentIndex])
                    )
                    
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
        .alert("End Practice Session?", isPresented: $showingCompletionAlert) {
            Button("Continue Practice", role: .cancel) { }
            
            Button("End Session") {
                navigateToResults = true
            }
        } message: {
            Text("Do you want to end this practice session? Your progress will be saved.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func toggleConfigSelection(_ config: PracticeConfiguration, isSelected: Bool) {
        if isSelected {
            selectedConfigurations.append(config)
        } else {
            selectedConfigurations.removeAll { $0.id == config.id }
        }
    }
    
    private func prepareSession() {
        // Prepare the practice session with words from selected configurations
        var practiceWords: [PracticeWord] = []
        
        for config in selectedConfigurations {
            // Get words for this configuration
            var words = config.selectedWordArray
            
            // If there are more words than the max per configuration, select random subset
            if words.count > maxWordsPerConfiguration {
                words = Array(words.shuffled().prefix(maxWordsPerConfiguration))
            }
            
            // Add to our practice words
            practiceWords.append(contentsOf: words)
        }
        
        // Shuffle the words
        currentPracticeWords = practiceWords.shuffled()
        
        // Initialize responses array
        responses = Array(repeating: nil, count: currentPracticeWords.count)
        
        // Start the practice session
        currentIndex = 0
        isConfiguringSession = false
    }
    
    private func recordResponse(_ correct: Bool?) {
        if currentIndex < responses.count {
            responses[currentIndex] = correct
        }
    }
    
    private func nextCard() {
        if currentIndex < currentPracticeWords.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            // We've reached the end of the practice session
            navigateToResults = true
        }
    }
    
    private func getConfigurationForWord(_ word: PracticeWord) -> PracticeConfiguration? {
        // Find which configuration this word belongs to
        for config in selectedConfigurations {
            if config.selectedWords?.contains(word) ?? false {
                return config
            }
        }
        return nil
    }
    
    private func getLevelForWord(_ word: PracticeWord) -> PhonemeLevel {
        if let config = getConfigurationForWord(word),
           let levelString = config.level,
           let level = PhonemeLevel.allCases.first(where: { $0.rawValue == levelString }) {
            return level
        }
        
        // Default to words level if not found
        return .words
    }
}

// MARK: - Configuration Selection Row
struct ConfigurationSelectionRow: View {
    @ObservedObject var configuration: PracticeConfiguration
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button {
            onToggle(!isSelected)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(configuration.phonemeSymbol ?? "")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text(configuration.phonemeName ?? "")
                            .font(.headline)
                    }
                    
                    HStack {
                        Text(configuration.positionFormatted)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(configuration.levelFormatted)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(configuration.selectedWordArray.count) words")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .disabled(configuration.selectedWordArray.isEmpty)
        .opacity(configuration.selectedWordArray.isEmpty ? 0.6 : 1.0)
    }
}

// MARK: - Practice Word Card
struct PracticeWordCard: View {
    let word: String
    let level: PhonemeLevel
    
    var body: some View {
        VStack {
            Text(formatWordForLevel(word, level: level))
                .font(.system(size: getFontSize(for: level), weight: .semibold))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
        }
    }
    
    // Format word based on level (reusing logic from PracticeWord model)
    private func formatWordForLevel(_ word: String, level: PhonemeLevel) -> String {
        switch level {
        case .isolation:
            // Just return first character as placeholder
            return String(word.prefix(1))
        case .syllable:
            // Create a simple syllable
            return word.prefix(2).lowercased()
        case .words:
            // Just the word itself
            return word
        case .phrases:
            // Create a simple phrase
            let prefixes = ["the big", "my little", "a nice", "two red", "some blue"]
            return "\(prefixes.randomElement() ?? "the") \(word)"
        case .sentences:
            // Create a simple sentence
            let templates = [
                "I see the \(word).",
                "Look at the \(word).",
                "The \(word) is nice.",
                "We have a \(word).",
                "Can you find the \(word)?"
            ]
            return templates.randomElement() ?? "I like the \(word)."
        }
    }
    
    // Adjust font size based on level (longer text for sentences needs smaller font)
    private func getFontSize(for level: PhonemeLevel) -> CGFloat {
        switch level {
        case .isolation, .syllable:
            return 60
        case .words:
            return 48
        case .phrases:
            return 36
        case .sentences:
            return 28
        }
    }
}

// MARK: - Session Results View
struct SessionResultsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let list: PracticeList
    let configurations: [PracticeConfiguration]
    let responses: [Bool?]
    let practiceWords: [PracticeWord]
    
    @State private var navigateToHome = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Results header
                VStack(alignment: .center, spacing: 8) {
                    Text("Practice Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Great job practicing with \(list.name ?? "your list")")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                // Overall results
                VStack(alignment: .leading, spacing: 16) {
                    Text("Overall Results")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        // Accuracy chart
                        ProgressCircle(percentage: correctPercentage)
                            .frame(width: 120, height: 120)
                        
                        // Result breakdown
                        VStack(alignment: .leading, spacing: 8) {
                            ResultRow(label: "Total Words", value: "\(practiceWords.count)", color: .blue)
                            ResultRow(label: "Correct", value: "\(correctCount)", color: .green)
                            ResultRow(label: "Incorrect", value: "\(incorrectCount)", color: .red)
                            ResultRow(label: "Skipped", value: "\(skippedCount)", color: .orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Results per phoneme
                VStack(alignment: .leading, spacing: 16) {
                    Text("Results by Phoneme")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(configurations, id: \.id) { config in
                        let configResults = getResultsForConfiguration(config)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(config.phonemeSymbol ?? "")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                
                                Text(config.phonemeName ?? "")
                                    .font(.headline)
                                
                                Spacer()
                                
                                if configResults.total > 0 {
                                    let percentage = Int((Double(configResults.correct) / Double(configResults.total)) * 100)
                                    
                                    Text("\(percentage)%")
                                        .font(.headline)
                                        .foregroundColor(
                                            percentage >= 80 ? .green :
                                                (percentage >= 60 ? .orange : .red)
                                        )
                                }
                            }
                            
                            HStack {
                                Text("\(config.positionFormatted) • \(config.levelFormatted)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(configResults.correct)/\(configResults.total) correct")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Progress bar
                            if configResults.total > 0 {
                                ProgressBar(
                                    correctCount: configResults.correct,
                                    incorrectCount: configResults.incorrect,
                                    skippedCount: configResults.skipped,
                                    totalCount: configResults.total
                                )
                                .frame(height: 12)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        saveResults()
                        dismiss()
                    } label: {
                        Text("Return to Practice List")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        saveResults()
                        navigateToHome = true
                    } label: {
                        Text("Return to Home")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Session Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Save results automatically when view appears
            saveResults()
        }
    }
    
    // MARK: - Helper Properties
    
    private var correctCount: Int {
        responses.filter { $0 == true }.count
    }
    
    private var incorrectCount: Int {
        responses.filter { $0 == false }.count
    }
    
    private var skippedCount: Int {
        responses.filter { $0 == nil }.count
    }
    
    private var correctPercentage: Int {
        let totalResponded = correctCount + incorrectCount
        guard totalResponded > 0 else { return 0 }
        return Int((Double(correctCount) / Double(totalResponded)) * 100)
    }
    
    // MARK: - Helper Methods
    
    private func getResultsForConfiguration(_ config: PracticeConfiguration) -> (total: Int, correct: Int, incorrect: Int, skipped: Int) {
        var total = 0
        var correct = 0
        var incorrect = 0
        var skipped = 0
        
        // Get indices of words belonging to this configuration
        let indices = practiceWords.indices.filter { index in
            let word = practiceWords[index]
            return config.selectedWords?.contains(word) ?? false
        }
        
        // Count results for those indices
        for index in indices {
            if index < responses.count {
                total += 1
                
                if responses[index] == true {
                    correct += 1
                } else if responses[index] == false {
                    incorrect += 1
                } else {
                    skipped += 1
                }
            }
        }
        
        return (total, correct, incorrect, skipped)
    }
    
    private func saveResults() {
        // Create a new practice session record
        let session = PracticeSession(context: viewContext)
        session.id = UUID()
        session.date = Date()
        session.list = list
        session.totalWords = Int16(practiceWords.count)
        session.correctCount = Int16(correctCount)
        session.incorrectCount = Int16(incorrectCount)
        session.skippedCount = Int16(skippedCount)
        
        // Add configuration results
        for config in configurations {
            let results = getResultsForConfiguration(config)
            
            let configResult = ConfigurationResult(context: viewContext)
            configResult.id = UUID()
            configResult.configurationID = config.id
            configResult.phonemeSymbol = config.phonemeSymbol
            configResult.totalWords = Int16(results.total)
            configResult.correctCount = Int16(results.correct)
            configResult.session = session
        }
        
        // Update last practiced date
//        list.lastPracticedAt = Date()
        
        // Save the context
        do {
            try viewContext.save()
        } catch {
            print("Error saving session results: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct ResultRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct ProgressBar: View {
    let correctCount: Int
    let incorrectCount: Int
    let skippedCount: Int
    let totalCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Correct section
                Rectangle()
                    .fill(Color.green)
                    .frame(width: getWidth(for: correctCount, in: geometry))
                
                // Incorrect section
                Rectangle()
                    .fill(Color.red)
                    .frame(width: getWidth(for: incorrectCount, in: geometry))
                
                // Skipped section
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: getWidth(for: skippedCount, in: geometry))
            }
            .cornerRadius(6)
        }
    }
    
    private func getWidth(for count: Int, in geometry: GeometryProxy) -> CGFloat {
        guard totalCount > 0 else { return 0 }
        let percentage = Double(count) / Double(totalCount)
        return geometry.size.width * CGFloat(percentage)
    }
}

// MARK: - Preview
struct PracticeSessionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let previewList = PracticeList.createPreviewList(context: context)
        
        return NavigationStack {
            PracticeSessionView(list: previewList)
                .environment(\.managedObjectContext, context)
        }
    }
}

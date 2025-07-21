//
//  PracticeListDetailView.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import SwiftUI
import CoreData

struct PracticeListDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var list: PracticeList
    
    @State private var showingWordSelection = false
    @State private var selectedConfiguration: PracticeConfiguration?
    @State private var showingEditSheet = false
    @State private var editName = ""
    @State private var editDescription = ""
    @State private var navigateToPractice = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                header
                
                // Configurations section
                configurationsSection
                
                // Progress section
                if list.sessionArray.count > 0 {
                    progressSection
                }
                
                // Practice button
                startPracticeButton
            }
            .padding()
        }
        .navigationTitle(list.name ?? "Practice List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editName = list.name ?? ""
                    editDescription = list.descriptionText ?? ""
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingWordSelection) {
            if let configuration = selectedConfiguration {
                NavigationStack {
                    WordSelectionView(configuration: configuration)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditPracticeListView(
                    name: $editName,
                    description: $editDescription,
                    onSave: saveListChanges
                )
            }
        }
        .background(
            NavigationLink(destination: PracticeSessionView(list: list), isActive: $navigateToPractice) {
                EmptyView()
            }
        )
    }
    
    // MARK: - Header Section
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let description = list.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(list.totalWordCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(list.configurationArray.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("configurations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(list.sessionArray.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Configurations Section
    private var configurationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configurations")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(list.configurationArray) { config in
                ConfigurationDetailRow(configuration: config) {
                    // Select this configuration
                    selectedConfiguration = config
                    showingWordSelection = true
                }
            }
            
            // Add configuration button
            NavigationLink(destination: AddConfigurationToListView(list: list)) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Configuration")
                }
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack {
                // Overall progress chart
                if let mostRecentSession = list.mostRecentSession {
                    HStack {
                        ProgressCircle(percentage: mostRecentSession.accuracyPercentage)
                            .frame(width: 80, height: 80)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last Session")
                                .font(.headline)
                            
                            Text("\(mostRecentSession.formattedDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 2) {
                                Image(systemName: list.progressTrend.icon)
                                    .foregroundColor(Color(list.progressTrend.color))
                                
                                Text(trendDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // List of recent sessions
                    if list.sessionArray.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent Sessions")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            ForEach(list.sessionArray.prefix(3)) { session in
                                HStack {
                                    Text(session.formattedDate)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text("\(session.accuracyPercentage)% correct")
                                        .font(.subheadline)
                                        .foregroundColor(session.accuracyPercentage >= 80 ? .green : (session.accuracyPercentage >= 60 ? .orange : .red))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Practice Button
    private var startPracticeButton: some View {
        Button {
            navigateToPractice = true
        } label: {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                Text("Start Practice")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.top, 20)
        .disabled(list.configurationArray.isEmpty)
        .opacity(list.configurationArray.isEmpty ? 0.6 : 1.0)
    }
    
    // MARK: - Helper Properties
    private var trendDescription: String {
        switch list.progressTrend {
        case .positive:
            return "Improving"
        case .negative:
            return "Needs work"
        case .neutral:
            return "Steady progress"
        }
    }
    
    // MARK: - Helper Methods
    private func saveListChanges() {
        list.name = editName
        list.descriptionText = editDescription
        
        do {
            try viewContext.save()
            showingEditSheet = false
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}

// MARK: - Configuration Detail Row
struct ConfigurationDetailRow: View {
    @ObservedObject var configuration: PracticeConfiguration
    let onSelectWords: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with phoneme info
            HStack {
                Text(configuration.phonemeSymbol ?? "")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text(configuration.phonemeName ?? "")
                    .font(.headline)
                
                Spacer()
                
                Text("\(configuration.selectedWordArray.count) words")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Position and level
            HStack {
                Text(configuration.positionFormatted)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text(configuration.levelFormatted)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Show some selected words
            if !configuration.selectedWordArray.isEmpty {
                Text("Selected words:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                Text(wordsList)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Select words button
            Button {
                onSelectWords()
            } label: {
                Text(configuration.selectedWordArray.isEmpty ? "Select Words" : "Edit Words")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
    
    private var wordsList: String {
        let words = configuration.selectedWordArray.prefix(4).map { $0.word ?? "" }
        let joinedWords = words.joined(separator: ", ")
        
        if configuration.selectedWordArray.count > 4 {
            return "\(joinedWords), +\(configuration.selectedWordArray.count - 4) more"
        }
        
        return joinedWords
    }
}

// MARK: - Progress Circle Component
struct ProgressCircle: View {
    let percentage: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.1)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(percentage) / 100.0, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: percentage)
            
            VStack(spacing: 0) {
                Text("\(percentage)%")
                    .font(.headline)
                
                Text("correct")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progressColor: Color {
        if percentage >= 80 {
            return .green
        } else if percentage >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Edit Practice List View
struct EditPracticeListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var name: String
    @Binding var description: String
    let onSave: () -> Void
    
    var body: some View {
        Form {
            Section {
                TextField("List Name", text: $name)
                TextField("Description (Optional)", text: $description)
            }
        }
        .navigationTitle("Edit List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

// MARK: - Add Configuration To List View
struct AddConfigurationToListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var list: PracticeList
    
    @State private var selectedPhoneme: Phoneme?
    @State private var selectedPosition: PhonemePosition?
    @State private var selectedLevel: PhonemeLevel?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Phoneme Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Phoneme")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(PhonemeData.phonemes) { phoneme in
                                Button {
                                    selectedPhoneme = phoneme
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(phoneme.symbol)
                                            .font(.system(.title2, design: .rounded))
                                            .fontWeight(.bold)
                                        
                                        Text(phoneme.name)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(selectedPhoneme?.id == phoneme.id ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedPhoneme?.id == phoneme.id ? .white : .primary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Position Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Position")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(PhonemePosition.allCases) { position in
                            Button {
                                selectedPosition = position
                            } label: {
                                VStack(spacing: 4) {
                                    Text(position.rawValue)
                                        .font(.headline)
                                    
                                    Text(position.description)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity)
                                .background(selectedPosition == position ? Color.blue : Color(.systemGray6))
                                .foregroundColor(selectedPosition == position ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Level Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Level")
                        .font(.headline)
                    
                    ForEach(PhonemeLevel.allCases) { level in
                        Button {
                            selectedLevel = level
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.rawValue)
                                        .font(.headline)
                                    
                                    Text(level.description)
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                if selectedLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(selectedLevel == level ? Color.blue : Color(.systemGray6))
                            .foregroundColor(selectedLevel == level ? .white : .primary)
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Add button
                Button {
                    addConfiguration()
                } label: {
                    Text("Add Configuration")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(selectedPhoneme == nil || selectedPosition == nil || selectedLevel == nil)
                .opacity((selectedPhoneme == nil || selectedPosition == nil || selectedLevel == nil) ? 0.6 : 1.0)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Add Configuration")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addConfiguration() {
        guard let phoneme = selectedPhoneme,
              let position = selectedPosition,
              let level = selectedLevel else {
            return
        }
        
        // Create a new configuration
        let config = PracticeConfiguration(context: viewContext)
        config.id = UUID()
        config.phonemeSymbol = phoneme.symbol
        config.phonemeName = phoneme.name
        config.position = position.rawValue
        config.level = level.rawValue
        config.list = list
        
        // Save the changes
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error adding configuration: \(error)")
        }
    }
}

// MARK: - Preview
struct PracticeListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let previewList = PracticeList.createPreviewList(context: context)
        
        return NavigationStack {
            PracticeListDetailView(list: previewList)
                .environment(\.managedObjectContext, context)
        }
    }
}

// MARK: - Helper Extension for Preview
extension PracticeList {
    static func createPreviewList(context: NSManagedObjectContext) -> PracticeList {
        let list = PracticeList(context: context)
        list.id = UUID()
        list.name = "Sample Practice List"
        list.descriptionText = "A sample list for previewing the detail view"
        list.createdAt = Date()
        
        let config1 = PracticeConfiguration(context: context)
        config1.id = UUID()
        config1.phonemeSymbol = "/r/"
        config1.phonemeName = "R Sound"
        config1.position = "initial"
        config1.level = "words"
        config1.list = list
        
        let config2 = PracticeConfiguration(context: context)
        config2.id = UUID()
        config2.phonemeSymbol = "/s/"
        config2.phonemeName = "S Sound"
        config2.position = "medial" 
        config2.level = "phrases"
        config2.list = list
        
        return list
    }
}
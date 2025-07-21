//
//  CreatePracticeListView.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import SwiftUI

struct CreatePracticeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var listName = ""
    @State private var listDescription = ""
    @State private var configurations: [ConfigurationItem] = []
    
    // Temporary state for creating a configuration
    @State private var isAddingConfiguration = false
    @State private var selectedPhoneme: Phoneme?
    @State private var selectedPosition: PhonemePosition?
    @State private var selectedLevel: PhonemeLevel?
    
    var body: some View {
        VStack {
            // Progress indicator
            ProgressView(value: Double(currentStep), total: 3)
                .padding(.horizontal)
                .padding(.top)
            
            HStack {
                Text("Step \(currentStep + 1) of 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(stepTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Step content
            ScrollView {
                VStack {
                    switch currentStep {
                    case 0:
                        basicInfoStep
                    case 1:
                        configurationsStep
                    case 2:
                        reviewStep
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                if currentStep < 2 {
                    Button(currentStep == 0 ? "Next" : "Review") {
                        withAnimation {
                            if canAdvance {
                                currentStep += 1
                            }
                        }
                    }
                    .padding()
                    .disabled(!canAdvance)
                } else {
                    Button("Create List") {
                        createPracticeList()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .disabled(configurations.isEmpty)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Create Practice List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isAddingConfiguration) {
            NavigationStack {
                AddConfigurationView(
                    selectedPhoneme: $selectedPhoneme,
                    selectedPosition: $selectedPosition,
                    selectedLevel: $selectedLevel,
                    onSave: { phoneme, position, level in
                        addConfiguration(phoneme: phoneme, position: position, level: level)
                        isAddingConfiguration = false
                    }
                )
            }
        }
    }
    
    // MARK: - Step 1: Basic Info
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Name Your Practice List")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Give your practice list a clear, descriptive name that you'll recognize later.")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("List Name")
                    .font(.headline)
                
                TextField("e.g., R and S Blends Practice", text: $listName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description (Optional)")
                    .font(.headline)
                
                TextField("e.g., Weekly practice for Jamie", text: $listDescription)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding(.top)
        }
    }
    
    // MARK: - Step 2: Configurations
    private var configurationsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Phoneme Configurations")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    // Reset temporary state
                    selectedPhoneme = nil
                    selectedPosition = nil
                    selectedLevel = nil
                    
                    // Show configuration sheet
                    isAddingConfiguration = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Text("Add the phonemes, positions, and levels you want to practice.")
                .foregroundColor(.secondary)
            
            if configurations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Configurations Yet")
                        .font(.headline)
                    
                    Text("Add phoneme configurations to practice")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        isAddingConfiguration = true
                    } label: {
                        Text("Add Configuration")
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(configurations.indices, id: \.self) { index in
                    ConfigurationItemView(config: configurations[index]) {
                        // Delete action
                        withAnimation {
                            configurations.remove(at: index)
                        }
                    }
                }
                
                Button {
                    isAddingConfiguration = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Another Configuration")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Step 3: Review
    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review Your Practice List")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(listName)
                    .font(.title3)
            }
            
            if !listDescription.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(listDescription)
                        .font(.subheadline)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Configurations")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(configurations.indices, id: \.self) { index in
                let config = configurations[index]
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(config.phoneme.symbol)")
                            .font(.system(.headline, design: .rounded))
                        
                        Text(config.phoneme.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(config.words.count) words")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("\(config.position.rawValue) position")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(config.level.rawValue) level")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 8)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                Text("After creating this list, you'll be able to select specific words for each configuration.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Properties
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Basic Information"
        case 1: return "Configurations"
        case 2: return "Review & Create"
        default: return ""
        }
    }
    
    private var canAdvance: Bool {
        switch currentStep {
        case 0: return !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: return !configurations.isEmpty
        default: return true
        }
    }
    
    // MARK: - Helper Methods
    private func addConfiguration(phoneme: Phoneme, position: PhonemePosition, level: PhonemeLevel) {
        // Create a new configuration item
        let newConfig = ConfigurationItem(
            id: UUID(),
            phoneme: phoneme,
            position: position,
            level: level,
            words: [] // Words will be selected later
        )
        
        // Add it to our configurations array
        configurations.append(newConfig)
    }
    
    private func createPracticeList() {
        // Create the practice list
        let list = PracticeList(context: viewContext)
        list.id = UUID()
        list.name = listName
        list.descriptionText = listDescription
        list.createdAt = Date()
        
        // Create configurations
        for configItem in configurations {
            let config = PracticeConfiguration(context: viewContext)
            config.id = UUID()
            config.phonemeSymbol = configItem.phoneme.symbol
            config.phonemeName = configItem.phoneme.name
            config.position = configItem.position.rawValue
            config.level = configItem.level.rawValue
            config.list = list
            
            // Here we'd normally add selected words, but that will be in the next step
            // after the list is created
        }
        
        // Save the context
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving list: \(error)")
        }
    }
}

// MARK: - Configuration Item Model
struct ConfigurationItem: Identifiable {
    var id: UUID
    var phoneme: Phoneme
    var position: PhonemePosition
    var level: PhonemeLevel
    var words: [PracticeWord]
}

// MARK: - Configuration Item View
struct ConfigurationItemView: View {
    let config: ConfigurationItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(config.phoneme.symbol)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text(config.phoneme.name)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(config.position.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text(config.level.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}

// MARK: - Add Configuration View
struct AddConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedPhoneme: Phoneme?
    @Binding var selectedPosition: PhonemePosition?
    @Binding var selectedLevel: PhonemeLevel?
    
    let onSave: (Phoneme, PhonemePosition, PhonemeLevel) -> Void
    
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
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Add Configuration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if let phoneme = selectedPhoneme,
                       let position = selectedPosition,
                       let level = selectedLevel {
                        onSave(phoneme, position, level)
                    }
                }
                .disabled(selectedPhoneme == nil || selectedPosition == nil || selectedLevel == nil)
            }
        }
    }
}

// MARK: - Preview
struct CreatePracticeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreatePracticeListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

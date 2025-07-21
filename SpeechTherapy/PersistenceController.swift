//
//  PersistenceController.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import CoreData
import SwiftUI

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SpeechTherapyModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Handle the Core Data error appropriately
                fatalError("Unable to load Core Data stores: \(error), \(error.userInfo)")
            }
        }
        
        // Enable automatic merging of changes from parent contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // For CloudKit integration (future implementation)
    func enableCloudKit() {
        guard let description = container.persistentStoreDescriptions.first else {
            return
        }
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "com.yourcompany.SpeechTherapy"
        )
    }
    
    // Save the managed object context if there are changes
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving Core Data context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Create an in-memory store for previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Add sample data to the in-memory store
        let viewContext = controller.container.viewContext
        
        // Create sample practice list
        let sampleList = PracticeList(context: viewContext)
        sampleList.id = UUID()
        sampleList.name = "R and S Blends Practice"
        sampleList.descriptionText = "For weekly practice of R and S blends"
        sampleList.createdAt = Date()
        
        // Create sample configurations
        let rConfig = PracticeConfiguration(context: viewContext)
        rConfig.id = UUID()
        rConfig.phonemeSymbol = "/r/"
        rConfig.phonemeName = "R Sound"
        rConfig.position = "initial"
        rConfig.level = "words"
        rConfig.list = sampleList
        
        let sConfig = PracticeConfiguration(context: viewContext)
        sConfig.id = UUID()
        sConfig.phonemeSymbol = "/s/"
        sConfig.phonemeName = "S Sound"
        sConfig.position = "medial"
        sConfig.level = "phrases"
        sConfig.list = sampleList
        
        // Create sample words
        let word1 = PracticeWord(context: viewContext)
        word1.id = UUID()
        word1.word = "run"
        word1.phonemeIndex = 0
        
        let word2 = PracticeWord(context: viewContext)
        word2.id = UUID()
        word2.word = "red"
        word2.phonemeIndex = 0
        
        let word3 = PracticeWord(context: viewContext)
        word3.id = UUID()
        word3.word = "sister"
        word3.phonemeIndex = 2
        
        // Create many-to-many relationships for words and configurations
        rConfig.addToSelectedWords(word1)
        rConfig.addToSelectedWords(word2)
        sConfig.addToSelectedWords(word3)
        
        try? viewContext.save()
        return controller
    }()
}

// Extension to provide convenience methods for creating and managing practice lists
extension PersistenceController {
    func createPracticeList(name: String, description: String? = nil) -> PracticeList {
        let newList = PracticeList(context: container.viewContext)
        newList.id = UUID()
        newList.name = name
        newList.descriptionText = description
        newList.createdAt = Date()
        
        save()
        return newList
    }
    
    func deletePracticeList(_ list: PracticeList) {
        container.viewContext.delete(list)
        save()
    }
    
    func addConfiguration(to list: PracticeList, phonemeSymbol: String, phonemeName: String, position: String, level: String) -> PracticeConfiguration {
        let config = PracticeConfiguration(context: container.viewContext)
        config.id = UUID()
        config.phonemeSymbol = phonemeSymbol
        config.phonemeName = phonemeName
        config.position = position
        config.level = level
        config.list = list
        
        save()
        return config
    }
    
    func addWord(to configuration: PracticeConfiguration, word: String, phonemeIndex: Int16) -> PracticeWord {
        let practiceWord = PracticeWord(context: container.viewContext)
        practiceWord.id = UUID()
        practiceWord.word = word
        practiceWord.phonemeIndex = phonemeIndex
        configuration.addToSelectedWords(practiceWord)
        
        save()
        return practiceWord
    }
    
    func savePracticeSession(for list: PracticeList, totalWords: Int, correct: Int, skipped: Int, incorrect: Int, configResults: [(id: UUID, phoneme: String, total: Int, correct: Int)]) -> PracticeSession {
        let session = PracticeSession(context: container.viewContext)
        session.id = UUID()
        session.date = Date()
        session.list = list
        session.totalWords = Int16(totalWords)
        session.correctCount = Int16(correct)
        session.skippedCount = Int16(skipped)
        session.incorrectCount = Int16(incorrect)
        
        // Add configuration results
        for result in configResults {
            let configResult = ConfigurationResult(context: container.viewContext)
            configResult.id = UUID()
            configResult.configurationID = result.id
            configResult.phonemeSymbol = result.phoneme
            configResult.totalWords = Int16(result.total)
            configResult.correctCount = Int16(result.correct)
            configResult.session = session
        }
        
        // Update the list's last practiced date
        list.lastPracticedAt = Date()
        
        save()
        return session
    }
}
//
//  PracticeListsView.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/17/25.
//


import SwiftUI
import CoreData

struct PracticeListsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PracticeList.lastPracticedAt, ascending: false)],
        animation: .default)
    private var practiceLists: FetchedResults<PracticeList>
    
    @State private var showingCreateSheet = false
    @State private var showingDeleteAlert = false
    @State private var listToDelete: PracticeList?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Featured Lists Section
                if !practiceLists.isEmpty {
                    featuredListsSection
                }
                
                List {
                    Section(header: Text("MY PRACTICE LISTS")) {
                        ForEach(practiceLists) { list in
                            NavigationLink(destination: PracticeListDetailView(list: list)) {
                                PracticeListRow(list: list)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    listToDelete = list
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        if practiceLists.isEmpty {
                            emptyStateView
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Practice Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                NavigationStack {
                    CreatePracticeListView()
                }
            }
            .alert("Delete Practice List", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let list = listToDelete {
                        deleteList(list)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this practice list? This action cannot be undone.")
            }
        }
    }
    
    // Featured Lists (horizontally scrollable cards)
    private var featuredListsSection: some View {
        VStack(alignment: .leading) {
            Text("FEATURED LISTS")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(practiceLists.prefix(3)) { list in
                        NavigationLink(destination: PracticeListDetailView(list: list)) {
                            FeaturedListCard(list: list)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    // Empty state view with call to action
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            
            Text("No Practice Lists")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Create custom practice lists for your sessions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreateSheet = true
            } label: {
                Text("Create Your First List")
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
    }
    
    // Delete a practice list
    private func deleteList(_ list: PracticeList) {
        withAnimation {
            viewContext.delete(list)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting list: \(error)")
            }
        }
    }
}

// MARK: - List Row Component
struct PracticeListRow: View {
    let list: PracticeList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(list.name ?? "Unnamed List")
                    .font(.headline)
                
                Spacer()
                
                Text("\(list.totalWordCount) words")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let description = list.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Show phonemes included in this list
            if !list.configurationArray.isEmpty {
                HStack {
                    ForEach(list.configurationArray.prefix(3)) { config in
                        Text(config.phonemeSymbol ?? "")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if list.configurationArray.count > 3 {
                        Text("+\(list.configurationArray.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }
            
            // Last practiced date if available
            if let lastPracticedAt = list.lastPracticedAt {
                Text("Last practiced: \(formatDate(lastPracticedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Featured List Card Component
struct FeaturedListCard: View {
    let list: PracticeList
    
    @State private var gradientColors: [Color] = [
        Color.blue,
        Color.purple
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text(list.name ?? "Unnamed List")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Spacer()
            
            // Stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(list.totalWordCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("words")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(list.configurationArray.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("sounds")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Progress section if sessions exist
            if let recentSession = list.mostRecentSession, list.sessionArray.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: list.progressTrend.icon)
                        .foregroundColor(Color(list.progressTrend.color))
                    
                    Text("\(recentSession.accuracyPercentage)% accuracy")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(width: 200, height: 150)
        .background(
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .onAppear {
            // Assign a gradient based on the first phoneme to create visual variety
            let phonemeSymbol = list.configurationArray.first?.phonemeSymbol ?? ""
            assignGradientColors(for: phonemeSymbol)
        }
    }
    
    // Set gradient colors based on phoneme to create visual distinction
    private func assignGradientColors(for phonemeSymbol: String) {
        switch phonemeSymbol.prefix(2) {
        case "/p", "/b", "/m":
            gradientColors = [Color.blue, Color.purple]
        case "/t", "/d", "/n":
            gradientColors = [Color.green, Color.blue]
        case "/k", "/g", "/h":
            gradientColors = [Color.orange, Color.red]
        case "/f", "/v", "/θ":
            gradientColors = [Color.purple, Color.pink]
        case "/s", "/z", "/ʃ":
            gradientColors = [Color.teal, Color.green]
        case "/r", "/l", "/w":
            gradientColors = [Color.pink, Color.purple]
        default:
            gradientColors = [Color.indigo, Color.blue]
        }
    }
}

// MARK: - Preview
struct PracticeListsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        return PracticeListsView()
            .environment(\.managedObjectContext, context)
            .environmentObject(UserPreferences())
    }
}
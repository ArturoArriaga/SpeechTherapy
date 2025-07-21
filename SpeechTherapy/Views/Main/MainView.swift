import SwiftUI

struct MainView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var selectedTab = "articulation"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Articulation tab (from your existing code)
            NavigationStack {
                ArticulationView()
                    .environmentObject(userPreferences)
                    .navigationTitle("Articulation")
            }
            .tabItem {
                Label("Sounds", systemImage: "waveform")
            }
            .tag("articulation")
            
            // NEW: Practice Lists tab
            NavigationStack {
                PracticeListsView()
                    .environmentObject(userPreferences)
            }
            .tabItem {
                Label("My Lists", systemImage: "list.bullet.clipboard")
            }
            .tag("lists")
            
            // Progress tab (placeholder for future implementation)
            NavigationStack {
                ProgressView()
                    .environmentObject(userPreferences)
                    .navigationTitle("Progress")
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }
            .tag("progress")
            
            // Settings tab (from your existing code)
            NavigationStack {
                SettingsView()
                    .environmentObject(userPreferences)
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag("settings")
        }
        .onAppear {
            // Configure the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// MARK: - Progress View (Placeholder)
struct ProgressView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Progress Tracking")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Track your practice sessions and monitor improvement over time.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // In a real app, you would implement progress tracking visualizations here
            
            // Placeholders for progress charts
            HStack(spacing: 20) {
                ProgressChartPlaceholder(title: "Weekly", icon: "calendar")
                ProgressChartPlaceholder(title: "Phonemes", icon: "waveform")
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

// MARK: - Progress Chart Placeholder
struct ProgressChartPlaceholder: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.2))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.blue.opacity(0.5))
                )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserPreferences())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

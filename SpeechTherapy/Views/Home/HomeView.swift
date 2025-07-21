import SwiftUI

// MARK: - Content Item Models
struct Category: Identifiable {
    let id = UUID()
    let title: String
    let items: [Item]
}

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let year: String
}

// MARK: - Card Views
struct ItemCard: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(item.year)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .frame(width: 170)
    }
}

struct RecentItemCard: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
            
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(item.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 170)
    }
}

// MARK: - Section Views
struct CategorySection: View {
    let title: String
    let items: [Item]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(items) { item in
                        ItemCard(item: item)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

struct FeaturedSection: View {
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Featured For You")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(categories) { category in
                CategorySection(title: category.title, items: category.items)
            }
        }
        .padding(.bottom, 16)
    }
}

struct RecentSection: View {
    let items: [Item]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recently Viewed")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(items) { item in
                        RecentItemCard(item: item)
                    }
                }
            }
        }
    }
}

// MARK: - Content View
struct HomeView: View {
    @State private var showSettings = false
    
    // Sample Data
    let featuredCategories = [
        Category(
            title: "New Additions",
            items: [
                Item(title: "Item One", subtitle: "Description", year: "2025"),
                Item(title: "Item Two", subtitle: "Description", year: "2025"),
                Item(title: "Item Three", subtitle: "Description", year: "2024"),
                Item(title: "Item Four", subtitle: "Description", year: "2024")
            ]
        ),
        Category(
            title: "View Again",
            items: [
                Item(title: "Item Five", subtitle: "Description", year: "2025"),
                Item(title: "Item Six", subtitle: "Description", year: "2023"),
                Item(title: "Item Seven", subtitle: "Description", year: "2024"),
                Item(title: "Item Eight", subtitle: "Description", year: "2022")
            ]
        ),
        Category(
            title: "Made For You",
            items: [
                Item(title: "Item Nine", subtitle: "Description", year: "2025"),
                Item(title: "Item Ten", subtitle: "Description", year: "2025"),
                Item(title: "Item Eleven", subtitle: "Description", year: "2024"),
                Item(title: "Item Twelve", subtitle: "Description", year: "2023")
            ]
        )
    ]
    
    let recentItems = [
        Item(title: "Recent Item One", subtitle: "Description", year: "2025"),
        Item(title: "Recent Item Two", subtitle: "Description", year: "2025"),
        Item(title: "Recent Item Three", subtitle: "Description", year: "2024"),
        Item(title: "Recent Item Four", subtitle: "Description", year: "2024"),
        Item(title: "Recent Item Five", subtitle: "Description", year: "2023")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    FeaturedSection(categories: featuredCategories)
                    
                    RecentSection(items: recentItems)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
}

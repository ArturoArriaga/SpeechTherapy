//
//  SelectorComponents.swift
//  SpeechTherapy
//
//  Created for SpeechTherapy app on 5/11/25.
//

import SwiftUI

// MARK: - MultiSelectButton
// A button that can be toggled for multi-selection
struct MultiSelectButton<T: Identifiable>: View {
    let item: T
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - HorizontalSelector
// A horizontal scrolling component for selecting options
struct HorizontalSelector<T: Identifiable & CaseIterable>: View where T: RawRepresentable, T.RawValue == String {
    let title: String
    let items: [T]
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(items), id: \.id) { item in
                        Button(action: {
                            selection = item
                        }) {
                            Text(item.rawValue)
                                .font(.subheadline)
                                .fontWeight(selection == item ? .bold : .regular)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selection == item ? Color.blue : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(selection == item ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - MultiSelectHorizontalSelector
// A horizontal scrolling component that allows multiple selections
struct MultiSelectHorizontalSelector<T: Identifiable & CaseIterable & Hashable>: View where T: RawRepresentable, T.RawValue == String {
    let title: String
    let items: [T]
    @Binding var selection: Set<T>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(items), id: \.id) { item in
                        Button(action: {
                            if selection.contains(item) {
                                selection.remove(item)
                                // If empty, add at least one back in
                                if selection.isEmpty {
                                    selection.insert(item)
                                }
                            } else {
                                selection.insert(item)
                            }
                        }) {
                            Text(item.rawValue)
                                .font(.subheadline)
                                .fontWeight(selection.contains(item) ? .bold : .regular)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selection.contains(item) ? Color.blue : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(selection.contains(item) ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - WordSelectorRow
// A row component for selecting a word
struct WordSelectorRow: View {
    let word: PracticeWord
    let index: Int
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: {
            action(index)
        }) {
            HStack {
                Text(word.word)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: word.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(word.isSelected ? .blue : .gray)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

// MARK: - WordSelectorSection
// A section for selecting target practice words
struct WordSelectorSection: View {
    let title: String
    @Binding var practicePlan: PracticePlan
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if isExpanded {
                Button(action: {
                    // Toggle select all words
                    let shouldSelect = !practicePlan.allWordsSelected
                    practicePlan.toggleAllWords(selected: shouldSelect)
                }) {
                    HStack {
                        Text(practicePlan.allWordsSelected ? "Deselect All" : "Select All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Image(systemName: practicePlan.allWordsSelected ? "minus.circle" : "plus.circle")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                Text("Selected: \(practicePlan.selectedWordCount) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack {
                    ForEach(0..<practicePlan.selectedWords.count, id: \.self) { index in
                        WordSelectorRow(
                            word: practicePlan.selectedWords[index],
                            index: index,
                            action: { idx in
                                practicePlan.toggleWordSelection(at: idx)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

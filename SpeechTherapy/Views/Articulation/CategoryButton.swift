//
//  CategoryButton.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/10/25.
//

import SwiftUI

struct CategoryButton: View {
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

#if DEBUG
struct CategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            CategoryButton(title: "Consonants", isSelected: true) {
                print("Consonants selected")
            }
            CategoryButton(title: "Blends", isSelected: false) {
                print("Blends selected")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif

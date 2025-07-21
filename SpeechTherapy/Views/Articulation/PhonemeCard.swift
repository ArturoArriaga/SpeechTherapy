//
//  PhonemeCard.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 5/10/25.
//

import SwiftUI


struct PhonemeCard: View {
    let phoneme: Phoneme
    let isUnlocked: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 8) {
                Text(phoneme.symbol)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isUnlocked ? .primary : .secondary)

                Text(phoneme.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isUnlocked ? .primary : .secondary)

                Text("e.g., \(phoneme.example)")
                    .font(.subheadline)
                    .foregroundColor(isUnlocked ? .secondary : .secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(minWidth: 120, minHeight: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(isUnlocked ? 0.1 : 0.05), radius: 5, x: 0, y: 2)
            )
            .opacity(isUnlocked ? 1.0 : 0.8)
            .overlay(
                !isUnlocked ?
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                : nil
            )

            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .padding(8)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if DEBUG
struct PhonemeCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PhonemeCard(
                phoneme: Phoneme(
                    symbol: "s",
                    name: "S Sound",
                    example: "sun",
                    category: .consonants,
                    subcategory: "Fricatives", language: .english
                ),
                isUnlocked: true
            )
            PhonemeCard(
                phoneme: Phoneme(
                    symbol: "r",
                    name: "R Sound",
                    example: "run",
                    category: .consonants,
                    subcategory: "Liquids"
                    , language: .english
                ),
                isUnlocked: false
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif

//
//  Transaction.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import Foundation

// API Response wrapper
struct TransactionsResponse: Codable {
    let transactions: [TransactionAPI]
}

// API Transaction model (matches backend response)
struct TransactionAPI: Codable {
    let id: Int
    let chargeName: String
    let amount: Double
    let location: String
    let category: String
    let timestamp: String
    let utility: String
}

// Main Transaction model for the app
struct Transaction: Codable, Identifiable {
    let id: UUID
    let apiId: Int?  // Store the API id for updates
    let chargeName: String
    let timestamp: Date
    let amount: Double
    let location: String?
    let category: String?
    let emoji: String?
    let aligned: String?

    // Custom coding keys to handle both local and API data
    enum CodingKeys: String, CodingKey {
        case id, apiId, chargeName, timestamp, amount, location, category, emoji, aligned
    }

    init(id: UUID = UUID(), apiId: Int? = nil, chargeName: String, timestamp: Date = Date(), amount: Double, location: String? = nil, category: String? = nil, emoji: String? = nil, aligned: String? = nil) {
        self.id = id
        self.apiId = apiId
        self.chargeName = chargeName
        self.timestamp = timestamp
        self.amount = amount
        self.location = location
        self.category = category
        self.emoji = emoji
        self.aligned = aligned
    }

    // Convenience initializer from API model
    init(from apiTransaction: TransactionAPI) {
        self.id = UUID()
        self.apiId = apiTransaction.id
        self.chargeName = apiTransaction.chargeName
        self.amount = apiTransaction.amount
        self.location = apiTransaction.location
        self.category = apiTransaction.category
        self.emoji = Self.emojiForCategory(apiTransaction.category)

        // Parse ISO 8601 timestamp
        let formatter = ISO8601DateFormatter()
        self.timestamp = formatter.date(from: apiTransaction.timestamp) ?? Date()

        // Map "utility" to "aligned" (convert "not assigned" to nil)
        self.aligned = apiTransaction.utility == "not assigned" ? nil : apiTransaction.utility
    }

    // Helper to assign emojis based on category
    private static func emojiForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food": return "🍽️"
        case "personal care": return "💇"
        case "education": return "📚"
        case "transportation", "transport": return "🚗"
        case "entertainment": return "🎬"
        case "fashion": return "👕"
        default: return "💰"
        }
    }
}

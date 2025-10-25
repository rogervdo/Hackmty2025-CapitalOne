//
//  Transaction.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: UUID
    let chargeName: String
    let timestamp: Date
    let amount: Double
    let location: String?
    let category: String?
    let aligned: String?
    
    init(id: UUID = UUID(), chargeName: String, timestamp: Date = Date(), amount: Double, location: String? = nil, category: String? = nil, aligned: String? = nil) {
        self.id = id
        self.chargeName = chargeName
        self.timestamp = timestamp
        self.amount = amount
        self.location = location
        self.category = category
        self.aligned = aligned
    }
}

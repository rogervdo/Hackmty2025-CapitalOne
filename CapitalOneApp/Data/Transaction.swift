//
//  Transaction.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import Foundation

struct Transaction: Codable, Identifiable {
    var id: UUID { UUID() }
    let name: String
    let amount: Decimal
    let timestamp: Date
    let location: String?
    
    init(name: String, amount: Decimal, timestamp: Date = Date(), location: String? = nil) {
        self.name = name
        self.amount = amount
        self.timestamp = timestamp
        self.location = location
    }
}

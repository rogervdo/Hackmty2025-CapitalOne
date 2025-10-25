//
//  Meta.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import Foundation

struct Meta: Codable, Identifiable{
    let id: UUID
    let amount: Int
    let metaName: String
    let duration: Int
    let startDate: Date
    
    init(id: UUID = UUID(), amount: Int, metaName: String, duration: Int, startDate: Date){
        self.id = id
        self.amount = amount
        self.metaName = metaName
        self.duration = duration
        self.startDate = startDate
    }
}

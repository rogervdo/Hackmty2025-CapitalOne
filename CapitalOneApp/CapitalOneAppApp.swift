//
//  CapitalOneAppApp.swift
//  CapitalOneApp
//
//  Created by Bryan Meza on 25/10/25.
//

import SwiftUI

@main
struct CapitalOneAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Add any app-level initialization here
                    print("✅ App launched successfully")
                }
        }
    }
}

//
//  ContentView.swift
//  CapitalOneApp
//
//  Created by Bryan Meza on 25/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var isAuthenticated = false

        var body: some View {
            ZStack {
                if isAuthenticated {
                    MainTabView()
                } else {
                    WelcomeView(onAuthenticated: { isAuthenticated = true })
                }

                if showSplash {
                    SplashView()
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeInOut(duration: 0.4)) { showSplash = false }
                }
            }
        }
    }

#Preview {
    ContentView()
}

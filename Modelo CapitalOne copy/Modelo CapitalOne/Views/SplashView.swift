//
//  SplashView.swift
//  Modelo CapitalOne
//
//  Created by Angel Aarón Muñoz Alvarez on 25/10/25.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.86
    @State private var opacity: Double = 0.0
    @State private var shimmer = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(white: 0.98), Color(white: 0.95)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image("capitalone_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260)
                    .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
                    .overlay { // barrido de brillo
                        ShimmerStrip(move: shimmer)
                            .mask(
                                Image("capitalone_logo")
                                    .resizable()
                                    .scaledToFit()
                            )
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.linear(duration: 1.2).delay(0.3).repeatForever(autoreverses: false)) {
                shimmer.toggle()
            }
        }
    }
}

private struct ShimmerStrip: View {
    var move: Bool
    var body: some View {
        LinearGradient(stops: [
            .init(color: .clear,              location: 0.00),
            .init(color: .white.opacity(0.9), location: 0.48),
            .init(color: .clear,              location: 0.95)
        ], startPoint: .top, endPoint: .bottom)
        .frame(width: 180)
        .rotationEffect(.degrees(18))
        .offset(x: move ? 320 : -320)
        .blendMode(.screen)
    }
}


#Preview {
    SplashView()
}

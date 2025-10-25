//
//  WelcomeView.swift
//  CapitalOneApp
//
//  Created by Angel Aarón Muñoz Alvarez on 25/10/25.
//

import SwiftUI
import LocalAuthentication

struct WelcomeView: View {
    var onAuthenticated: () -> Void

    @State private var floatIcon = false
    @State private var shine = false
    @State private var canBio = false
    @State private var bioError: String?

    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundGradient()
                DecorativeBlobs()
                
                VStack(spacing: 24) {
                    // LOGO Capital One
                    Image("capitalone_logo")
                      .resizable().scaledToFit().frame(width: 160)
                      .opacity(0.95).padding(.top, 36)
                      .accessibilityHidden(true)
                    
                    // Ícono/app badge animado (el mismo de antes)
                    AppIconBadge(shine: $shine)
                        .padding(.top, 6)
                    
                    // Texto
                    VStack(spacing: 10) {
                        Text("Welcome")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                        Text("Manage your money wisely with your financial coach")
                            .font(.system(.title3, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 520)
                            .padding(.horizontal)
                    }
                    

                    Spacer(minLength: 20)

                    // ====== TUS BOTONES PRINCIPALES ======
                    VStack(spacing: 16) {
                        NavigationLink {
                            LoginView()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill").imageScale(.large)
                                Text("Sign in").font(.system(.title3, design: .rounded).weight(.semibold))
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                        }
                        .buttonStyle(CoachFilledButtonStyle())

                        Button {
                            // TODO: ir a crear cuenta
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Sign up").font(.system(.title3, design: .rounded).weight(.semibold))
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                        }
                        .buttonStyle(CoachOutlineButtonStyle())
                    }
                    .padding(.horizontal)

                    // ====== BIOMETRÍA ======
                    if canBio {
                        Button(action: authenticateBiometric) {
                            Label(bioLabelText(), systemImage: bioSystemImage())
                                .font(.callout.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .tint(.secondary)
                        .padding(.top, 6)
                    }

                    // Nota de seguridad
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                        Text("Your data is protected and secure")
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
            .onAppear { updateBiometryAvailability() }
            .alert("Unable to authenticate", isPresented: .constant(bioError != nil), actions: {
                Button("OK") { bioError = nil }
            }, message: { Text(bioError ?? "") })
        }
    }

    // MARK: - Biometría
    private func updateBiometryAvailability() {
        let ctx = LAContext()
        canBio = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    private func bioSystemImage() -> String {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType == .faceID ? "faceid" : "touchid"
    }

    private func bioLabelText() -> String {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType == .faceID ? "Sign in with Face ID" : "Sign in with Touch ID"
    }

    private func authenticateBiometric() {
        let ctx = LAContext()
        var error: NSError?

        // 1) FaceID/TouchID
        if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Entrar de forma segura") { success, evalError in
                DispatchQueue.main.async {
                    if success { onAuthenticated() }
                    else { bioError = (evalError as NSError?)?.localizedDescription ?? "Cancelado" }
                }
            }
            return
        }

        // 2) Fallback: passcode del sistema (si lo prefieres)
        if ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            ctx.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: "Confirma tu identidad") { success, evalError in
                DispatchQueue.main.async {
                    if success { onAuthenticated() }
                    else { bioError = (evalError as NSError?)?.localizedDescription ?? "Cancelado" }
                }
            }
            return
        }

        bioError = error?.localizedDescription ?? "Biometría no disponible en este dispositivo"
    }
}



// MARK: - App Icon Badge
private struct AppIconBadge: View {
    @Binding var shine: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color.capitalOneBlue, Color.capitalOneCobalt],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 148, height: 148)
                .shadow(color: .black.opacity(0.18), radius: 24, y: 14)
                .overlay {
                    // Soft inner blobs (glass look)
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 82)
                        .offset(x: 18, y: -26)
                        .blur(radius: 2)
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 120)
                        .offset(x: -26, y: 30)
                        .blur(radius: 2)
                }
                .overlay(alignment: .center) {
                    // Center glyph
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                }
                .overlay {
                    // Shimmer pass
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 0.8)
                        .blendMode(.screen)
                        .mask(alignment: .leading) {
                            Rectangle()
                                .fill(
                                    LinearGradient(stops: [
                                        .init(color: .clear, location: 0.0),
                                        .init(color: .white.opacity(0.9), location: 0.45),
                                        .init(color: .clear, location: 0.9)
                                    ], startPoint: .top, endPoint: .bottom)
                                )
                                .rotationEffect(.degrees(18))
                                .offset(x: shine ? 180 : -180)
                        }
                }
                .offset(y: -6)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: shine)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Background
private struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(colors: [Color(white: 0.98), Color(white: 0.95)],
                       startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
        .overlay(
            LinearGradient(colors: [.clear, .black.opacity(0.05)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

private struct DecorativeBlobs: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color.capitalOneCobalt.opacity(0.42), .clear],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -130, y: -220)
                .opacity(animate ? 0.75 : 0.55)
            
            Circle()
                .fill(LinearGradient(colors: [.clear, Color.capitalOneBlue.opacity(0.38)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: 140, y: 240)
                .opacity(animate ? 0.7 : 0.5)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

struct CoachFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [Color.capitalOneBlue, Color.capitalOneCobalt],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color.capitalOneBlue.opacity(0.35), radius: 16, y: 10)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct CoachOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.capitalOneBlue)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.capitalOneBlue.opacity(0.9), lineWidth: 1.6)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.65))
                    )
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

extension Color {
    static let capitalOneBlue   = Color(hex: 0x0A58CC)   // Cobalt-ish
    static let capitalOneCobalt = Color(hex: 0x003C7E)   // Deep navy
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: alpha)
    }
}






#Preview() {
    WelcomeView(onAuthenticated: {})
}

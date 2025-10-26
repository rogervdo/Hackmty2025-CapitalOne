//
//  Preferencias.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI

struct PerfilView: View {
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header del perfil
                    ProfileHeaderView()
                    
                    // Opciones del menú
                    VStack(spacing: 12) {
                        MenuItemView(
                            icon: "person.circle",
                            title: "Datos personales",
                            action: { }
                        )
                        
                        MenuItemView(
                            icon: "bell",
                            title: "Notificaciones",
                            action: { }
                        )
                        
                        MenuItemView(
                            icon: "lock",
                            title: "Seguridad",
                            action: { }
                        )
                        
                        MenuItemView(
                            icon: "gearshape",
                            title: "Preferencias",
                            isSelected: true,
                            action: { }
                        )
                        
                        MenuItemView(
                            icon: "questionmark.circle",
                            title: "Ayuda",
                            action: { }
                        )
                        
                        MenuItemView(
                            icon: "shield",
                            title: "Legal y privacidad",
                            action: { }
                        )
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Footer con versión
                    VStack(spacing: 8) {
                        Text("Versión 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2025 Banco Digital. Todos los derechos reservados.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Botón de cerrar sesión
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Text("Cerrar sesión")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Cerrar sesión", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar sesión", role: .destructive) {
                // Implementar lógica de logout
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?")
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                // Avatar del usuario
                Circle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("MG")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Demo Account")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("demo@email.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
    }
}

struct MenuItemView: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
}

#Preview {
    PerfilView()
}


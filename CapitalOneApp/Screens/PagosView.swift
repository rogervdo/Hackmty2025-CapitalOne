//
//  Pagos.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI

struct PagosView: View {
    @State private var selectedTransferType: TransferType = .entreMisCuentas
    @State private var selectedSourceAccount: String = ""
    @State private var selectedDestinationAccount: String = ""
    @State private var amount: String = ""
    @State private var concept: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Transfer Type Selection
                    transferTypeSelection
                    
                    // From Account Section
                    fromAccountSection
                    
                    // To Account Section
                    toAccountSection
                    
                    // Amount Section
                    amountSection
                    
                    // Concept Section
                    conceptSection
                    
                    // Transfer Button
                    transferButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pagos y Transferencias")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        Text("Pagos y Transferencias")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    private var transferTypeSelection: some View {
        HStack(spacing: 12) {
            TransferTypeButton(
                title: "Entre mis\ncuentas",
                isSelected: selectedTransferType == .entreMisCuentas,
                action: { selectedTransferType = .entreMisCuentas }
            )
            
            TransferTypeButton(
                title: "A otro\nbanco",
                isSelected: selectedTransferType == .aOtroBanco,
                action: { selectedTransferType = .aOtroBanco }
            )
            
            TransferTypeButton(
                title: "Servicios",
                isSelected: selectedTransferType == .servicios,
                action: { selectedTransferType = .servicios }
            )
            
            Spacer()
        }
    }
    
    private var fromAccountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Desde")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            AccountCard(
                accountType: "Cuenta Cheques",
                balance: "$18,420",
                subtitle: "Saldo disponible"
            )
        }
    }
    
    private var toAccountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hacia")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Button(action: {
                // Handle destination account selection
            }) {
                HStack {
                    Text("Selecciona cuenta destino")
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monto")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack {
                TextField("$0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Button(action: {
                    // Handle calculator or quick amount selection
                }) {
                    Image(systemName: "grid.3x3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var conceptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Concepto (opcional)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("Ej: Ahorro mensual", text: $concept)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var transferButton: some View {
        Button(action: {
            // Handle transfer action
            performTransfer()
        }) {
            Text("Transferir")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(amount.isEmpty || selectedDestinationAccount.isEmpty)
        .padding(.top, 20)
    }
    
    private func performTransfer() {
        // Implement transfer logic here
        print("Performing transfer of \(amount) from \(selectedSourceAccount) to \(selectedDestinationAccount)")
        if !concept.isEmpty {
            print("Concept: \(concept)")
        }
    }
}

// MARK: - Supporting Views

struct TransferTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(minWidth: 80)
                .background(
                    isSelected ?
                    LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

struct AccountCard: View {
    let accountType: String
    let balance: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(accountType)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(balance)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Enums

enum TransferType {
    case entreMisCuentas
    case aOtroBanco
    case servicios
}

// MARK: - Preview

#Preview {
    PagosView()
}


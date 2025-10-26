import SwiftUI

// MARK: - Emoji API Response
struct EmojiResponse: Decodable {
    let emoji: String
    let category: String
}

// MARK: - Movement model (CORREGIDA: Eliminamos 'mutating')
struct DashboardMovement: Identifiable {
    let id = UUID()
    var emoji: String = "💰" // Default emoji, will be updated from API
    let title: String
    let subtitle: String
    let amount: String
    let tag: String
    let tagColor: Color
    // NOTA: Eliminamos la función 'updateEmoji' de la estructura.
}

// MARK: - Dashboard View
struct DashboardView: View {
    // ⚠️ AJUSTAR: URL base de tu API
    private let baseURL = "https://unitycampus.onrender.com"
    
    @Binding var selectedTab: Int
    @State private var movements: [DashboardMovement] = []
    
    // Initial movement data
    private let initialMovements = [
        DashboardMovement(title: "Uber Eats", subtitle: "Hoy 12:24 · Centro", amount: "$160", tag: "Regret", tagColor: .red),
        DashboardMovement(title: "Café Azul", subtitle: "Ayer · Tec", amount: "$55", tag: "Regret", tagColor: .red),
        DashboardMovement(title: "Soriana", subtitle: "23 Oct", amount: "$420", tag: "Aligned", tagColor: .blue),
        DashboardMovement(title: "Netflix", subtitle: "21 Oct", amount: "$129", tag: "Regret", tagColor: .red),
        DashboardMovement(title: "Uber", subtitle: "20 Oct · Trabajo", amount: "$85", tag: "Aligned", tagColor: .blue)
    ]
    
    // FUNCIÓN DE RED (AUXILIAR, NO ASOCIADA A LA ESTRUCTURA)
    private func fetchEmoji(for title: String) async -> String? {
        guard let url = URL(string: "\(baseURL)/emojis") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["prompt": title]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONDecoder().decode(EmojiResponse.self, from: data) {
                return response.emoji
            } else if let jsonString = String(data: data, encoding: .utf8) {
                // Fallback robusto para JSON no estándar (similar a tu lógica de FastAPI)
                if let emojiPart = jsonString.split(separator: "\"emoji\":").last?.split(separator: ",").first {
                    let cleanEmoji = String(emojiPart).replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cleanEmoji.isEmpty {
                        return cleanEmoji
                    }
                }
            }
        } catch {
            print("Error fetching emoji: \(error.localizedDescription)")
        }
        return nil
    }
    
    // CORRECCIÓN CLAVE: Función de carga que gestiona el estado
    private func loadAndCategorizeMovements() {
        // 1. Iniciar con los datos estáticos
        movements = initialMovements
        
        // 2. Tarea asíncrona para actualizar los emojis
        for index in movements.indices {
            let title = movements[index].title
            
            Task {
                if let newEmoji = await fetchEmoji(for: title) {
                    // Actualizar el estado en el hilo principal
                    await MainActor.run {
                        // Verificación de rango por seguridad
                        if index < self.movements.count {
                            self.movements[index].emoji = newEmoji
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                HStack(alignment: .top) {
                    Text("Inicio")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // CARD: Saldo total
                BalanceCard()
                    .padding(.horizontal, 16)
                
                // CARD: Meta semanal ahorro
                WeeklyGoalCard()
                    .padding(.horizontal, 16)
                
                // ROW: Dos cards pequeñas
                HStack(spacing: 12) {
                    SmallStatCard(
                        title: "Cap discrecional",
                        value: "$1,000",
                        subtitleTop: "Rebasado en $240",
                        subtitleColor: .red
                    )
                    SmallStatCard(
                        title: "Proyección meta",
                        value: "12 ene",
                        subtitleTop: "Con hábitos actuales",
                        subtitleColor: .secondary
                    )
                }
                .padding(.horizontal, 16)
                
                // CARD: Acciones rápidas
                QuickActionsCard()
                    .padding(.horizontal, 16)
                
                // Lista: Movimientos recientes
                VStack(alignment: .leading, spacing: 16) {
                    Text("Movimientos recientes")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        ForEach(movements.prefix(5)) { mov in
                            // SINTAXIS CORREGIDA del Button
                            Button(action: {
                                // 🔥 go to Movs tab (index 1)
                                selectedTab = 1
                            }) {
                                DashboardMovementRow(movement: mov)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .onAppear {
                    if movements.isEmpty {
                        loadAndCategorizeMovements()
                    }
                }
                
                // CARD: Coach financiero
                CoachCard(selectedTab: $selectedTab)    // 🔥 pass binding
                    .padding(.horizontal, 16)
                
                Spacer(minLength: 32)
            }
            .background(Color(.systemGray6))
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Movement Row (Se mantiene igual)
private struct DashboardMovementRow: View {
    let movement: DashboardMovement
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                Text(movement.emoji) // Usará el emoji actualizado
                    .font(.system(size: 28))
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(movement.title)
                        .font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Text(movement.amount)
                        .font(.system(size: 17, weight: .semibold))
                }
                
                Text(movement.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(movement.tag)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(movement.tagColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(movement.tagColor.opacity(0.12))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Componentes Auxiliares (Sin cambios)

private struct BalanceCard: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 32/255, green: 79/255, blue: 1.0),
                        Color(red: 25/255, green: 60/255, blue: 0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 180, height: 180)
                .offset(x: 40, y: -30)
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 220, height: 220)
                .offset(x: 70, y: 40)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Saldo total")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
                
                Text("$30,720")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cheques")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.8))
                        Text("$18,420")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ahorro")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.8))
                        Text("$12,300")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WeeklyGoalCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Meta semanal ahorro")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Text("37%")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            HStack {
                Text("$1,800 objetivo")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Faltan $1,140")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: geo.size.width * 0.37, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
        )
    }
}

private struct SmallStatCard: View {
    let title: String
    let value: String
    let subtitleTop: String
    let subtitleColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .semibold))
            
            Text(subtitleTop)
                .font(.system(size: 15))
                .foregroundColor(subtitleColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
        )
    }
}

private struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acciones rápidas")
                .font(.system(size: 17, weight: .semibold))
            
            HStack(spacing: 12) {
                QuickActionButton(title: "Transferir", systemIcon: "arrow.right.arrow.left.circle.fill")
                QuickActionButton(title: "Pagar\nservicio", systemIcon: "creditcard.circle.fill")
                QuickActionButton(title: "Enviar", systemIcon: "paperplane.circle.fill")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
        )
    }
}

private struct QuickActionButton: View {
    let title: String
    let systemIcon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: systemIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

private struct CoachCard: View {
    @Binding var selectedTab: Int    // 🔥 added
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("💡")
                        .font(.system(size: 20))
                    Text("Ahorra más esta semana")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text("Descubre oportunidades para alcanzar tu meta antes")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Button {
                // 🔥 go straight to Coach tab (index 2)
                selectedTab = 2
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.green)
                    Text("Abrir Coach")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.green)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.1, green: 0.6, blue: 0.2),
                                    Color(red: 0.07, green: 0.5, blue: 0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .offset(x: -40, y: -20)
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 180, height: 180)
                    .offset(x: 80, y: 40)
            }
        )
    }
}

// MARK: - Preview
#Preview {
    // preview with a constant binding
    DashboardView(selectedTab: .constant(0))
}

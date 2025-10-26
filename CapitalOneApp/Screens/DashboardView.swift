import SwiftUI

// MARK: - Movement model
struct DashboardMovement: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let subtitle: String
    let amount: String
    let tag: String
    let tagColor: Color
}

// MARK: - Dashboard View
struct DashboardView: View {
    
    @Binding var selectedTab: Int   // 🔥 added
    
    let recentMovements: [DashboardMovement] = [
        DashboardMovement(emoji: "🍔", title: "Uber Eats", subtitle: "Hoy 12:24 · Centro", amount: "$160", tag: "Regret", tagColor: .red),
        DashboardMovement(emoji: "☕️", title: "Café Azul", subtitle: "Ayer · Tec", amount: "$55", tag: "Regret", tagColor: .red),
        DashboardMovement(emoji: "🛒", title: "Soriana", subtitle: "23 Oct", amount: "$420", tag: "Aligned", tagColor: .blue),
        DashboardMovement(emoji: "🎬", title: "Netflix", subtitle: "21 Oct", amount: "$129", tag: "Regret", tagColor: .red),
        DashboardMovement(emoji: "🚗", title: "Uber", subtitle: "20 Oct · Trabajo", amount: "$85", tag: "Aligned", tagColor: .blue)
    ]
    
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
                        ForEach(recentMovements.prefix(5)) { mov in
                            Button {
                                // 🔥 go to Movs tab (index 1)
                                selectedTab = 1
                            } label: {
                                DashboardMovementRow(movement: mov)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                // CARD: Coach financiero
                CoachCard(selectedTab: $selectedTab)   // 🔥 pass binding
                    .padding(.horizontal, 16)
                
                Spacer(minLength: 32)
            }
            .background(Color(.systemGray6))
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Balance Card
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

// MARK: - Weekly Goal Card
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

// MARK: - Small Stat Card
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

// MARK: - Quick Actions Card
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

// MARK: - Movement Row
private struct DashboardMovementRow: View {
    let movement: DashboardMovement
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                Text(movement.emoji)
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

// MARK: - Coach Card
private struct CoachCard: View {
    @Binding var selectedTab: Int   // 🔥 added
    
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

import SwiftUI
import Charts

// MARK: - API Responses

struct GastosWrapper: Decodable {
    let gastos: [GastoResponse]
}

struct GastoResponse: Decodable {
    let chargeName: String
    let amount: Double
    let timeStamp: String
    let location: String
    let category: String
    let utility: String
}

struct EmojiResponse: Decodable {
    let emoji: String
    let category: String
}

// MARK: - UI models

struct DashboardMovement: Identifiable {
    let id = UUID()
    var emoji: String = "💰"
    let title: String
    let subtitle: String
    let amount: String
    let tag: String
    let tagColor: Color
}

// para el pie chart
struct CategorySlice: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
}

// MARK: - Dashboard View

struct DashboardView: View {
    private let baseURL = "https://unitycampus.onrender.com"
    private let userID = 1
    
    @Binding var selectedTab: Int
    
    @State private var movements: [DashboardMovement] = []
    @State private var categorySlices: [CategorySlice] = []
    
    // estado de carga global
    @State private var isLoadingData = true
    
    // MARK: helper: llama /emojis
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
            
            if let decoded = try? JSONDecoder().decode(EmojiResponse.self, from: data) {
                return decoded.emoji
            }
            if let raw = String(data: data, encoding: .utf8),
               let rangeEmoji = raw.range(of: "\"emoji\":") {
                let after = raw[rangeEmoji.upperBound...]
                if let comma = after.firstIndex(of: ",") {
                    let piece = after[..<comma]
                    let clean = piece
                        .replacingOccurrences(of: "\"", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !clean.isEmpty { return clean }
                }
            }
        } catch {
            print("❌ fetchEmoji error:", error.localizedDescription)
        }
        return nil
    }
    
    // MARK: cargar gastos + movimientos + categorias
    private func loadAndCategorizeMovements() {
        Task {
            guard let url = URL(string: "\(baseURL)/gastos/\(userID)") else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard let decoded = try? JSONDecoder().decode(GastosWrapper.self, from: data) else {
                    print("❌ error decoding gastos JSON")
                    await MainActor.run {
                        self.isLoadingData = false
                    }
                    return
                }
                
                // top 5 recientes
                let firstFive = Array(decoded.gastos.prefix(5))
                
                // map para UI
                let mapped: [DashboardMovement] = firstFive.map { g in
                    let (tagText, tagColor): (String, Color) = {
                        switch g.utility.lowercased() {
                        case "regret":   return ("Regret", .red)
                        case "aligned":  return ("Aligned", .blue)
                        default:         return ("Not assigned", .gray)
                        }
                    }()
                    
                    let subtitleText = "\(g.timeStamp) · \(g.location)"
                    
                    return DashboardMovement(
                        emoji: "💳", // temp mientras llega el emoji real
                        title: g.chargeName,
                        subtitle: subtitleText,
                        amount: "$\(Int(g.amount))",
                        tag: tagText,
                        tagColor: tagColor
                    )
                }
                
                // pie chart data (todas las transacciones)
                let totalsByCategory: [String: Double] = decoded.gastos.reduce(into: [:]) { acc, g in
                    acc[g.category, default: 0] += g.amount
                }
                
                let slices: [CategorySlice] = totalsByCategory
                    .map { (cat, totalCat) in
                        CategorySlice(category: cat, total: totalCat)
                    }
                    .sorted { $0.total > $1.total }
                
                // update movimientos y chart slices
                await MainActor.run {
                    self.movements = mapped
                    self.categorySlices = slices
                }
                
                // pedir emoji para cada movimiento y actualizar
                for (idx, mov) in mapped.enumerated() {
                    if let newEmoji = await fetchEmoji(for: mov.title) {
                        await MainActor.run {
                            if idx < self.movements.count {
                                self.movements[idx].emoji = newEmoji
                            }
                        }
                    }
                }
                
            } catch {
                print("❌ network error:", error.localizedDescription)
            }
            
            // terminamos carga inicial
            await MainActor.run {
                self.isLoadingData = false
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
                
                // CARD: Pie Chart por categoría
                CategoryPieCard(
                    slices: categorySlices,
                    isLoading: isLoadingData
                )
                .padding(.horizontal, 16)
                
                // ROW: Dos cards pequeñas (dummy por ahora)
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
                        if isLoadingData {
                            // skeleton de 5 renglones
                            ForEach(0..<5, id: \.self) { _ in
                                DashboardMovementRow.skeleton()
                            }
                        } else {
                            ForEach(movements.prefix(5)) { mov in
                                Button(action: {
                                    selectedTab = 1 // ir a Movs tab
                                }) {
                                    DashboardMovementRow(movement: mov, showSkeleton: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .onAppear {
                    if movements.isEmpty && isLoadingData {
                        loadAndCategorizeMovements()
                    }
                }
                
                // CARD: Coach financiero
                CoachCard(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                
                Spacer(minLength: 32)
            }
            .background(Color(.systemGray6))
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Movement Row con skeleton support
private struct DashboardMovementRow: View {
    let movement: DashboardMovement
    var showSkeleton: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // avatar / emoji
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                
                if showSkeleton {
                    // bloque gris animado
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray4).opacity(0.4))
                        .frame(width: 28, height: 28)
                        .redacted(reason: .placeholder)
                        .shimmer()
                } else {
                    Text(movement.emoji)
                        .font(.system(size: 28))
                }
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if showSkeleton {
                        Rectangle()
                            .fill(Color(.systemGray4).opacity(0.4))
                            .frame(width: 120, height: 16)
                            .cornerRadius(4)
                            .redacted(reason: .placeholder)
                            .shimmer()
                        Spacer()
                        Rectangle()
                            .fill(Color(.systemGray4).opacity(0.4))
                            .frame(width: 50, height: 16)
                            .cornerRadius(4)
                            .redacted(reason: .placeholder)
                            .shimmer()
                    } else {
                        Text(movement.title)
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Text(movement.amount)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                
                if showSkeleton {
                    Rectangle()
                        .fill(Color(.systemGray4).opacity(0.4))
                        .frame(width: 180, height: 14)
                        .cornerRadius(4)
                        .redacted(reason: .placeholder)
                        .shimmer()
                } else {
                    Text(movement.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                if showSkeleton {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray4).opacity(0.4))
                        .frame(width: 80, height: 24)
                        .redacted(reason: .placeholder)
                        .shimmer()
                } else {
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
        )
    }
    
    // helper estático para skeleton
    static func skeleton() -> some View {
        DashboardMovementRow(
            movement: DashboardMovement(
                emoji: "💳",
                title: "-----",
                subtitle: "-----",
                amount: "$-",
                tag: "-----",
                tagColor: .gray
            ),
            showSkeleton: true
        )
    }
}

// MARK: - Pie Chart Card con loading
private struct CategoryPieCard: View {
    let slices: [CategorySlice]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Gasto por categoría")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
            }
            
            if isLoading {
                // loading view
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Cargando categorías…")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
            } else {
                // Pie chart real
                Chart(slices) { slice in
                    SectorMark(
                        angle: .value("Total", slice.total),
                        innerRadius: .ratio(0.55),
                        outerRadius: .ratio(0.95)
                    )
                    .foregroundStyle(by: .value("Category", slice.category))
                }
                .frame(height: 180)
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

// MARK: - shimmer modifier (mini)
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase)
                .blendMode(.plusLighter)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

private extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Other cards (sin cambios)

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
    @Binding var selectedTab: Int
    
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
                selectedTab = 2 // Coach tab
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
    DashboardView(selectedTab: .constant(0))
}

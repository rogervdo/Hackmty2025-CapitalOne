import SwiftUI
import MapKit


// Este modelo es SOLO para la lista y el detalle.
// No incluye GastoResponse para que no truenen los protocolos.
struct MovementRowModel: Identifiable, Hashable {
    let id = UUID()
    var emoji: String
    let title: String               // chargeName
    let subtitleTop: String         // category
    let subtitleBottom: String      // timestamp · location
    let amount: String              // "$160"
    let utility: String             // "aligned" / "regret" / "not assigned"
}

struct MovimientosView: View {

    @State private var movimientos: [MovementRowModel] = []
    @State private var selectedMovement: MovementRowModel? = nil
    @State private var isLoading = true

    // mismo user y baseURL que usas en Dashboard
    private let userID = 1
    private let baseURL = "https://unitycampus.onrender.com"

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    // loader CENTRADO en pantalla
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Loading transactions…")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))

                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {

                            // HEADER
                            Text("Transactions")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                                .padding(.horizontal, 16)

                            // LISTA
                            VStack(spacing: 12) {
                                ForEach(movimientos) { mov in
                                    Button {
                                        selectedMovement = mov
                                    } label: {
                                        MovementRow(mov: mov)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                    .background(Color(.systemGray6))
                }
            }
            .navigationDestination(item: $selectedMovement) { mov in
                MovementDetailView(movement: mov)
                    .background(Color(.systemGray6))
            }
            .task {
                await loadMovements()
            }
        }
    }

    // MARK: - Fetch all gastos del usuario
    func loadMovements() async {
        guard let url = URL(string: "\(baseURL)/gastos/\(userID)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            // Estas structs YA existen en tu proyecto por DashboardView:
            //  struct GastosWrapper: Decodable { let gastos: [GastoResponse] }
            //  struct GastoResponse: Decodable {
            //      let chargeName: String
            //      let amount: Double
            //      let timeStamp: String
            //      let location: String
            //      let category: String
            //      let utility: String
            //  }
            let decoded = try JSONDecoder().decode(GastosWrapper.self, from: data)

            // Mapeamos TODAS las transacciones (no solo 5)
            var mapped: [MovementRowModel] = decoded.gastos.map { g in
                let friendlyDate = g.timeStamp.toUserFriendlyDate()
                return MovementRowModel(
                    emoji: "💳", // placeholder mientras pedimos el emoji real
                    title: g.chargeName,
                    subtitleTop: g.category,
                    subtitleBottom: "\(friendlyDate) · \(g.location)",
                    amount: "$\(Int(g.amount))",
                    utility: g.utility
                )
            }

            // Pedimos un emoji por categoría y lo colocamos
            for index in mapped.indices {
                let cat = mapped[index].subtitleTop
                if let newEmoji = await fetchEmoji(for: cat) {
                    mapped[index].emoji = newEmoji
                }
            }

            await MainActor.run {
                self.movimientos = mapped
                self.isLoading = false
            }

        } catch {
            print("❌ Error loading movements:", error.localizedDescription)
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    // Igual que Dashboard: POST /emojis
    func fetchEmoji(for categoryOrName: String) async -> String? {
        guard let url = URL(string: "\(baseURL)/emojis") else { return nil }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["prompt": categoryOrName]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        req.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: req)

            // intento directo
            if let decoded = try? JSONDecoder().decode(EmojiResponse.self, from: data) {
                return decoded.emoji
            }

            // fallback por si /emojis regresa JSON medio raro (como en Dashboard)
            if let raw = String(data: data, encoding: .utf8),
               let rangeEmoji = raw.range(of: "\"emoji\":") {
                let after = raw[rangeEmoji.upperBound...]
                if let comma = after.firstIndex(of: ",") {
                    let piece = after[..<comma]
                    let clean = piece
                        .replacingOccurrences(of: "\"", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if !clean.isEmpty {
                        return clean
                    }
                }
            }

        } catch {
            print("❌ fetchEmoji error:", error.localizedDescription)
        }
        return nil
    }
}

// MARK: - Row UI (mismo look que DashboardMovementRow)
private struct MovementRow: View {
    let mov: MovementRowModel

    var chipColor: Color {
        switch mov.utility.lowercased() {
        case "aligned": return .blue
        case "regret": return .red
        default: return .gray
        }
    }

    var chipText: String {
        switch mov.utility.lowercased() {
        case "aligned": return "Aligned"
        case "regret": return "Regret"
        default: return "Not Assigned"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                Text(mov.emoji)
                    .font(.system(size: 28))
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(mov.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    Text(mov.amount)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Text(mov.subtitleTop)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(mov.subtitleBottom)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(chipText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(chipColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(chipColor.opacity(0.12))
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

// MARK: - Detail View
struct MovementDetailView: View {
    let movement: MovementRowModel

    // Oxxo centro MTY fijo
    private let coord = CLLocationCoordinate2D(latitude: 25.6714, longitude: -100.3090)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // 1. Info de la transacción (primero)
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                            Text(movement.emoji)
                                .font(.system(size: 32))
                        }
                        .frame(width: 56, height: 56)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(movement.title)
                                .font(.system(size: 22, weight: .semibold))

                            Text(movement.subtitleBottom)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)

                            Text(movement.amount)
                                .font(.system(size: 24, weight: .bold))
                        }
                        Spacer()
                    }

                    Divider()

                    HStack {
                        Text("Categoría")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(movement.subtitleTop)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal, 16)

                // 2. Mapa fijo (Oxxo centro)
                Map(
                    initialPosition: .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.01,
                                longitudeDelta: 0.01
                            )
                        )
                    )
                )
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)

                Spacer(minLength: 32)
            }
            .padding(.top, 16)
            .background(Color(.systemGray6))
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6))
    }
}

// MARK: - Preview
#Preview {
    MovimientosView()
}


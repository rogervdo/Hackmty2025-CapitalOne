import SwiftUI

// MARK: - Model
struct Movement: Identifiable, Hashable, Codable {
    let id: Int
    let emoji: String
    let name: String
    let description: String
    let date: String
    let place: String
    let amount: String
    let categoryText: String
    let classification: String
}

// MARK: - Movimientos View
struct MovimientosView: View {
    
    @State private var movements: [Movement] = []
    @State private var selectedMovement: Movement? = nil
    
    let userId: Int = 1  // Cambiar según el usuario actual
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // HEADER
                    Text("Transactions")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                    
                    // LIST
                    VStack(spacing: 16) {
                        ForEach(movements) { mov in
                            Button {
                                selectedMovement = mov
                            } label: {
                                MovementRow(movement: mov)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(item: $selectedMovement) { mov in
                MovementDetailView(movement: mov)
                    .background(Color(.systemGray6))
            }
            .task {
                await fetchMovements()
            }
        }
    }
    
    // MARK: - Fetch Movements from API
    func fetchMovements() async {
        do {
            guard let url = URL(string: "https://unitycampus.onrender.com/swipe/unclassified/\(userId)") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            
            struct ApiResponse: Codable {
                let transactions: [MovementResponse]
            }
            
            struct MovementResponse: Codable {
                let id: Int
                let chargeName: String
                let amount: Double
                let location: String
                let category: String
                let timestamp: String
                let utility: String
            }
            
            let decoded = try JSONDecoder().decode(ApiResponse.self, from: data)
            
            // Generar emojis
            var categoryEmojiMap: [String: String] = [:]
            for tx in decoded.transactions {
                if categoryEmojiMap[tx.category] == nil {
                    let emojiData = try await getEmoji(for: tx.category)
                    categoryEmojiMap[tx.category] = emojiData.emoji
                }
            }
            
            let loadedMovements: [Movement] = decoded.transactions.map { tx in
                Movement(
                    id: tx.id,
                    emoji: categoryEmojiMap[tx.category] ?? "🏷️",
                    name: tx.chargeName,
                    description: tx.category,
                    date: tx.timestamp,
                    place: tx.location,
                    amount: "$\(Int(tx.amount))",
                    categoryText: tx.category,
                    classification: tx.utility.capitalized
                )
            }
            
            DispatchQueue.main.async {
                self.movements = loadedMovements
            }
            
        } catch {
            print("Error fetching movements: \(error)")
        }
    }
    
    // MARK: - Get emoji from API
    func getEmoji(for category: String) async throws -> (emoji: String, category: String) {
        guard let url = URL(string: "https://unitycampus.onrender.com/emojis") else {
            return ("🏷️", category)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["prompt": category]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        struct EmojiResponse: Codable {
            let emoji: String
            let category: String
        }
        let decoded = try JSONDecoder().decode(EmojiResponse.self, from: data)
        return (decoded.emoji, decoded.category)
    }
}

// MARK: - Individual Row
struct MovementRow: View {
    let movement: Movement
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                Text(movement.emoji)
                    .font(.system(size: 28))
            }
            .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movement.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(movement.description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(movement.date)
                    Text("·")
                    Text(movement.place)
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(movement.amount)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(movement.classification)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.12))
                    )
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Detail View
struct MovementDetailView: View {
    let movement: Movement
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(movement.emoji)
                    .font(.system(size: 64))
                
                Text(movement.name)
                    .font(.title)
                    .bold()
                
                Text(movement.description)
                    .foregroundColor(.secondary)
                
                Text(movement.amount)
                    .font(.title2)
                
                Text(movement.place)
                Text(movement.date)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview("MovimientosView") {
    MovimientosView()
}

//
//  SwipeView.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI
import ConfettiSwiftUI

struct SwipeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true
    @State private var loadError: String?
    let userId: Int = 1  // Change based on your user

    @State private var currentIndex = 0
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var alignedCount = 0
    @State private var regretCount = 0
    @State private var isCompleted = false

    @State private var trigger = 0
    
    var body: some View {
        ZStack {
            // Dynamic glowing background based on swipe direction
            Rectangle()
                .fill(backgroundGlow)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.2), value: offset.width)

            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading transactions...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else if let error = loadError {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Error loading transactions")
                        .font(.headline)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        fetchUnclassifiedTransactions()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if isCompleted {
                completionView
            } else if transactions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("No transactions to review")
                        .font(.headline)
                    Text("All caught up!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("Back to Coach") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack {
                    // Header
                    headerView

                    Spacer()

                    // Card Stack
                    cardStackView

                    Spacer()

                    // Action Buttons
                    actionButtonsView

                    Spacer()
                }
                .padding()
            }
        }
        .confettiCannon(trigger: $trigger, num:30, confettiSize: 15, radius:400)
        .onAppear {
            fetchUnclassifiedTransactions()
        }
    }
    
    // Computed property for dynamic background glow
    private var backgroundGlow: LinearGradient {
        let swipeThreshold: CGFloat = 30
        let maxGlow: CGFloat = 0.3
        
        if offset.width > swipeThreshold {
            // Swiping right - green glow
            let intensity = min(abs(offset.width - swipeThreshold) / 100, 1.0) * maxGlow
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.1), location: 0.0),
                    .init(color: Color.green.opacity(intensity * 0.3), location: 0.7),
                    .init(color: Color.green.opacity(intensity), location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if offset.width < -swipeThreshold {
            // Swiping left - red glow
            let intensity = min(abs(offset.width + swipeThreshold) / 100, 1.0) * maxGlow
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.red.opacity(intensity), location: 0.0),
                    .init(color: Color.red.opacity(intensity * 0.3), location: 0.3),
                    .init(color: Color.black.opacity(0.1), location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            // Default state - subtle background
            return LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var headerView: some View {
        VStack {
            Text("Review Transactions")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(transactions.count - currentIndex) transactions remaining")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Undo button
            if currentIndex > 0 && transactions.prefix(currentIndex).contains(where: { $0.aligned != nil }) {
                Button(action: {
                    undoLastAction()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left")
                        Text("Undo")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .padding(.top, 8)
            }
        }
    }
    
    var cardStackView: some View {
        ZStack {
            // Show up to 3 cards for depth effect
            ForEach(Array(transactions.enumerated().reversed()), id: \.element.id) { index, transaction in
                if index >= currentIndex && index < currentIndex + 3 {
                    Transaction2CardView(transaction: transaction)
                        .offset(
                            x: index == currentIndex ? offset.width : 0,
                            y: CGFloat(index - currentIndex) * 5
                        )
                        .scaleEffect(index == currentIndex ? 1.0 : 0.95 - CGFloat(index - currentIndex) * 0.05)
                        .rotationEffect(.degrees(index == currentIndex ? rotation : 0))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: offset)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
                        .gesture(
                            index == currentIndex ?
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                    rotation = Double(gesture.translation.width / 20)
                                }
                                .onEnded { gesture in
                                    handleSwipeGesture(translation: gesture.translation)
                                } : nil
                        )
                }
            }
        }
        .frame(maxHeight: 500)
    }
    
    var actionButtonsView: some View {
        HStack(spacing: 60) {
            // Regret Button (Left Swipe)
            Button(action: {
                swipeLeft()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .scaleEffect(offset.width < -50 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: offset.width)
            
            // Aligned Button (Right Swipe)
            Button(action: {
                swipeRight()
            }) {
                Image(systemName: "checkmark")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .scaleEffect(offset.width > 50 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: offset.width)
        }
    }
    
    var completionView: some View {
        VStack(spacing: 30) {
            // Celebration animation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(1.2)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatCount(1, autoreverses: false), value: isCompleted)
            
            // Well done message
            Text("Well Done!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Statistics
            VStack(spacing: 20) {
                Text("Session Results")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 50) {
                    // Regret count
                    VStack {
                        Text("\(regretCount)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.red)
                        Text("Regrets")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    // Aligned count
                    VStack {
                        Text("\(alignedCount)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                        Text("Aligned")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
            
            // Action buttons
            VStack(spacing: 16) {
                // Reset button
                Button(action: {
                    resetSession()
                }) {
                    Text("Start New Session")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Back to Coach button
                Button(action: {
                    dismiss()
                }) {
                    Text("Back to Coach")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                                .fill(Color.clear)
                        )
                }
                .padding(.horizontal, 40)
            }
        }
        .padding()
    }
    
    private func handleSwipeGesture(translation: CGSize) {
        let swipeThreshold: CGFloat = 100
        
        if translation.width > swipeThreshold {
            swipeRight()
        } else if translation.width < -swipeThreshold {
            swipeLeft()
        } else {
            // Snap back to center
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offset = .zero
                rotation = 0
            }
        }
    }
    
    private func swipeLeft() {
        // Handle "Regret" action
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = CGSize(width: -500, height: 0)
            rotation = -20
        }
        
        // Update the transaction's aligned property
        transactions[currentIndex] = Transaction(
            id: transactions[currentIndex].id,
            chargeName: transactions[currentIndex].chargeName,
            timestamp: transactions[currentIndex].timestamp,
            amount: transactions[currentIndex].amount,
            location: transactions[currentIndex].location,
            category: transactions[currentIndex].category,
            emoji: transactions[currentIndex].emoji,
            aligned: "regret"
        )
        
        regretCount += 1
        
        // Log the swipe action with Transaction.category
        print("🔴 SWIPE LEFT (Regret)")
        print("   Transaction: \(transactions[currentIndex].chargeName)")
        print("   Amount: $\(String(format: "%.2f", transactions[currentIndex].amount))")
        print("   Aligned Value: regret")
        print("   Location: \(transactions[currentIndex].location ?? "Unknown")")
        print("   Timestamp: \(transactions[currentIndex].timestamp)")
        print("---")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            rotation = 0
            
            // Check if we've completed all transactions
            if currentIndex >= transactions.count {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    isCompleted = true
                }
                // Trigger confetti celebration and log session results
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    trigger += 1
                    logSessionResults()
                }
            }
        }
    }
    
    private func swipeRight() {
        // Handle "Aligned" action
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = CGSize(width: 500, height: 0)
            rotation = 20
        }
        
        // Update the transaction's aligned property
        transactions[currentIndex] = Transaction(
            id: transactions[currentIndex].id,
            chargeName: transactions[currentIndex].chargeName,
            timestamp: transactions[currentIndex].timestamp,
            amount: transactions[currentIndex].amount,
            location: transactions[currentIndex].location,
            category: transactions[currentIndex].category,
            emoji: transactions[currentIndex].emoji,
            aligned: "align"
        )
        
        alignedCount += 1
        
        // Log the swipe action with Transaction.category
        print("🟢 SWIPE RIGHT (Align)")
        print("   Transaction: \(transactions[currentIndex].chargeName)")
        print("   Amount: $\(String(format: "%.2f", transactions[currentIndex].amount))")
        print("   Aligned Value: align")
        print("   Location: \(transactions[currentIndex].location ?? "Unknown")")
        print("   Timestamp: \(transactions[currentIndex].timestamp)")
        print("---")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            rotation = 0
            
            // Check if we've completed all transactions
            if currentIndex >= transactions.count {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    isCompleted = true
                }
                // Trigger confetti celebration and log session results
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    trigger += 1
                    logSessionResults()
                }
            }
        }
    }
    
    private func undoLastAction() {
        guard currentIndex > 0 else { return }
        
        // Find the most recent transaction with an aligned value
        let previousIndex = currentIndex - 1
        guard let previousAligned = transactions[previousIndex].aligned else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex -= 1
            offset = .zero
            rotation = 0
            isCompleted = false
        }
        
        // Revert the transaction's aligned property
        transactions[previousIndex] = Transaction(
            id: transactions[previousIndex].id,
            chargeName: transactions[previousIndex].chargeName,
            timestamp: transactions[previousIndex].timestamp,
            amount: transactions[previousIndex].amount,
            location: transactions[previousIndex].location,
            category: transactions[previousIndex].category,
            emoji: transactions[previousIndex].emoji,
            aligned: nil
        )
        
        // Revert the count based on what was undone
        switch previousAligned {
        case "align":
            alignedCount -= 1
            print("↩️ UNDO ACTION")
            print("   Transaction: \(transactions[previousIndex].chargeName)")
            print("   Previous Aligned Value: align → nil")
            print("   Amount: $\(String(format: "%.2f", transactions[previousIndex].amount))")
            print("---")
        case "regret":
            regretCount -= 1
            print("↩️ UNDO ACTION")
            print("   Transaction: \(transactions[previousIndex].chargeName)")
            print("   Previous Aligned Value: regret → nil")
            print("   Amount: $\(String(format: "%.2f", transactions[previousIndex].amount))")
            print("---")
        default:
            break
        }
    }
    
    private func resetSession() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentIndex = 0
            alignedCount = 0
            regretCount = 0
            isCompleted = false
            offset = .zero
            rotation = 0
            
            // Reset all transactions' aligned property
            for i in transactions.indices {
                transactions[i] = Transaction(
                    id: transactions[i].id,
                    chargeName: transactions[i].chargeName,
                    timestamp: transactions[i].timestamp,
                    amount: transactions[i].amount,
                    location: transactions[i].location,
                    category: transactions[i].category,
                    emoji: transactions[i].emoji,
                    aligned: nil
                )
            }
        }
    }
    
    private func logSessionResults() {
        print("\n🎉 SESSION COMPLETED! 🎉")
        print("========================")
        print("📊 FINAL SESSION RESULTS:")
        print("   Total Transactions: \(transactions.count)")
        print("   Aligned: \(alignedCount)")
        print("   Regrets: \(regretCount)")
        print("========================")
        print("\n📋 ALL TRANSACTIONS WITH ALIGNED VALUES:")
        print("==========================================")

        for (index, transaction) in transactions.enumerated() {
            let alignedStatus = transaction.aligned ?? "unprocessed"
            let emoji = transaction.aligned == "align" ? "🟢" : transaction.aligned == "regret" ? "🔴" : "⚪"

            print("\(index + 1). \(emoji) \(transaction.chargeName)")
            print("   Amount: $\(String(format: "%.2f", transaction.amount))")
            print("   Location: \(transaction.location ?? "Unknown")")
            print("   Aligned Value: \(alignedStatus)")
            print("   Date: \(transaction.timestamp)")
            print("   ID: \(transaction.id)")
            print("   API ID: \(transaction.apiId ?? 0)")
            print("   ---")
        }

        print("==========================================")
        print("🔥 SESSION SUMMARY ARRAY:")
        let sessionSummary = transactions.map { transaction in
            return [
                "apiId": transaction.apiId ?? 0,
                "chargeName": transaction.chargeName,
                "amount": transaction.amount,
                "aligned": transaction.aligned ?? "unprocessed",
                "location": transaction.location ?? "Unknown",
                "id": transaction.id.uuidString
            ] as [String : Any]
        }

        print(sessionSummary)
        print("==========================================\n")
    }

    // MARK: - API Networking
    private func fetchUnclassifiedTransactions() {
        isLoading = true
        loadError = nil

        guard let url = URL(string: "https://unitycampus.onrender.com/swipe/unclassified/\(userId)") else {
            loadError = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.loadError = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.loadError = "No data received"
                    self.isLoading = false
                    return
                }

                // Debug: Print raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📡 API Response:")
                    print(jsonString)
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(TransactionsResponse.self, from: data)

                    // Convert API transactions to app transactions
                    self.transactions = response.transactions.map { Transaction(from: $0) }

                    print("✅ Successfully loaded \(self.transactions.count) transactions")

                    self.isLoading = false
                } catch {
                    self.loadError = "Failed to decode: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

struct Transaction2CardView: View {
    let transaction: Transaction
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    // Dynamic gradient based on amount
    private var amountGradient: LinearGradient {
        let intensity = min(transaction.amount / 100.0, 1.0)
        return LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.8 + intensity * 0.2),
                Color.mint.opacity(0.6 + intensity * 0.4)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Modern header with glassmorphism effect
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.chargeName)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(transaction.category ?? "Uncategorized")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Modern amount display with gradient
                    Text("$\(String(format: "%.2f", transaction.amount))")
                        .font(.system(.title, design: .rounded, weight: .heavy))
                        .foregroundStyle(amountGradient)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    Capsule()
                                        .stroke(amountGradient, lineWidth: 1)
                                }
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Elegant separator
            Rectangle()
                .fill(.quaternary)
                .frame(height: 1)
                .padding(.horizontal, 24)
            
            // Transaction.category with modern styling
            VStack(spacing: 16) {
                ModernDetailRow(icon: "calendar", title: "Date & Time", 
                              value: dateFormatter.string(from: transaction.timestamp))
                ModernDetailRow(icon: "location.fill", title: "Location", 
                              value: transaction.location ?? "Unknown")
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Enhanced emoji display with backdrop
            if let emoji = transaction.emoji {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 160)
                        .overlay {
                            Circle()
                                .stroke(.quaternary, lineWidth: 1)
                        }
                    
                    Text(emoji)
                        .font(.system(size: 80))
                        .scaleEffect(1.1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Spacer()
            
            // Modern swipe hints with glass effect
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                        .font(.system(.caption, weight: .semibold))
                    Text("Regret")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(.red.opacity(0.1))
                        .overlay {
                            Capsule()
                                .stroke(.red.opacity(0.3), lineWidth: 1)
                        }
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("Aligned")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                    Image(systemName: "arrow.right")
                        .font(.system(.caption, weight: .semibold))
                }
                .foregroundStyle(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(.green.opacity(0.1))
                        .overlay {
                            Capsule()
                                .stroke(.green.opacity(0.3), lineWidth: 1)
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            // Modern card background with subtle gradient and glass effect
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .white.opacity(0.2), location: 0.0),
                                    .init(color: .clear, location: 0.3),
                                    .init(color: .clear, location: 0.7),
                                    .init(color: .black.opacity(0.1), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.quaternary, lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
        }
    }
}

// Modern detail row component
struct ModernDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(.quaternary.opacity(0.5))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
    }
}



// Preview
#Preview {
    SwipeView()
}

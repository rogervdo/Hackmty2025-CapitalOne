//
//  SwipeView.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI

struct Transaction2{
    let id = UUID()
    let chargeName: String
    let timestamp: Date
    let amount: Double
    let location: String
}

struct SwipeView: View {
    @State private var transactions: [Transaction] = [
        Transaction(chargeName: "Starbucks Coffee", timestamp: Date().addingTimeInterval(-3600), amount: 5.45, location: "Downtown Plaza"),
        Transaction(chargeName: "Uber Ride", timestamp: Date().addingTimeInterval(-7200), amount: 12.30, location: "Main St to Airport"),
        Transaction(chargeName: "Target", timestamp: Date().addingTimeInterval(-86400), amount: 45.67, location: "Target Center"),
        Transaction(chargeName: "Netflix Subscription", timestamp: Date().addingTimeInterval(-172800), amount: 15.99, location: "Online"),
        Transaction(chargeName: "Gas Station", timestamp: Date().addingTimeInterval(-259200), amount: 32.50, location: "Shell Station"),
        Transaction(chargeName: "Restaurant", timestamp: Date().addingTimeInterval(-345600), amount: 28.75, location: "Olive Garden")
    ]
    
    @State private var currentIndex = 0
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
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
    
    var headerView: some View {
        VStack {
            Text("Review Transaction2s")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(transactions.count - currentIndex) transactions remaining")
                .font(.subheadline)
                .foregroundColor(.secondary)
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
                        .opacity(index == currentIndex ? 1.0 : 0.8 - Double(index - currentIndex) * 0.2)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex < transactions.count - 1 {
                currentIndex += 1
            }
            offset = .zero
            rotation = 0
        }
        
        print("Swiped LEFT (Regret): \(transactions[currentIndex].chargeName)")
    }
    
    private func swipeRight() {
        // Handle "Aligned" action
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = CGSize(width: 500, height: 0)
            rotation = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex < transactions.count - 1 {
                currentIndex += 1
            }
            offset = .zero
            rotation = 0
        }
        
        print("Swiped RIGHT (Aligned): \(transactions[currentIndex].chargeName)")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with charge name
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.chargeName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Transaction Details")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Amount
                Text("$\(String(format: "%.2f", transaction.amount))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Divider()
            
            // Transaction details
            VStack(spacing: 15) {
                DetailRow(icon: "calendar", title: "Date & Time", value: dateFormatter.string(from: transaction.timestamp))
                DetailRow(icon: "location", title: "Location", value: transaction.location!)
                DetailRow(icon: "creditcard", title: "Amount", value: "$\(String(format: "%.2f", transaction.amount))")
            }
            
            Spacer()
            
            // Swipe hints
            HStack {
                Label("Regret", systemImage: "arrow.left")
                    .font(.caption)
                    .foregroundColor(.red)
                
                Spacer()
                
                Label("Aligned", systemImage: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
        }
        .padding(25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// Preview
#Preview {
    SwipeView()
}

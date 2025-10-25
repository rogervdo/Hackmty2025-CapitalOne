//
//  Movements.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI
import MapKit

// MARK: - Model
struct Movement: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
    let description: String
    let date: String
    let place: String
    let amount: String
    let categoryText: String
    let classification: String
}

// MARK: - Main Movements View
struct MovementsView: View {
    
    // Sample Data
    let movements: [Movement] = [
        Movement(
            emoji: "🍔",
            name: "Uber Eats",
            description: "Burger order with delivery",
            date: "Today 12:24",
            place: "Downtown",
            amount: "$160",
            categoryText: "Delivery",
            classification: "Regret"
        ),
        Movement(
            emoji: "☕️",
            name: "Café Azul",
            description: "Vanilla latte + sweet bread",
            date: "Today 09:15",
            place: "Campus",
            amount: "$55",
            categoryText: "Coffee",
            classification: "Regret"
        ),
        Movement(
            emoji: "🛍️",
            name: "Rappi",
            description: "Quick groceries / night snack",
            date: "Yesterday 20:30",
            place: "Home",
            amount: "$185",
            categoryText: "Delivery",
            classification: "Regret"
        ),
        Movement(
            emoji: "🍵",
            name: "Starbucks",
            description: "Matcha latte venti",
            date: "Yesterday 08:45",
            place: "Downtown",
            amount: "$65",
            categoryText: "Coffee",
            classification: "Regret"
        )
    ]
    
    @State private var selectedMovement: Movement? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // HEADER
                    Text("Transaction")
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
        }
    }
}

// MARK: - Individual Row
struct MovementRow: View {
    let movement: Movement
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Emoji icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                Text(movement.emoji)
                    .font(.system(size: 28))
            }
            .frame(width: 56, height: 56)
            
            // Info section
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
            
            // Amount and badge
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

// MARK: - Map Pin
struct MapPin: Identifiable {
    let id = UUID()
    let location: CLLocationCoordinate2D
}

// MARK: - Map Card (Monterrey Center with closer zoom)
struct MapCardView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    private let pins = [
        MapPin(location: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161))
    ]
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: pins) { pin in
            MapAnnotation(coordinate: pin.location) {
                VStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .shadow(radius: 2)
                    Text("Downtown")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(true)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(height: 180)
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 3)
    }
}

// MARK: - Detail View
struct MovementDetailView: View {
    let movement: Movement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1. Purchase Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                            Text(movement.emoji)
                                .font(.system(size: 28))
                        }
                        .frame(width: 48, height: 48)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movement.name)
                                .font(.system(size: 20, weight: .semibold))
                            Text(movement.date)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    Text(movement.amount)
                        .font(.system(size: 28, weight: .semibold))
                    
                    Divider()
                    
                    HStack {
                        Text("Category")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(movement.categoryText)
                            .font(.system(size: 16))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 16)
                
                // 2. Map
                MapCardView()
                
                // 3. Classification
                VStack(alignment: .leading, spacing: 12) {
                    Text("Classification")
                        .font(.system(size: 17, weight: .semibold))
                    
                    HStack(spacing: 12) {
                        Text("Aligned")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                            )
                        
                        Text("Regret")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red, lineWidth: 1.5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.08))
                                    )
                            )
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 16)

                // 4. Why is this in this category?
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                        Text("Why is this in this category?")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletRow(text: "Detected 4 deliveries this week vs your limit of 2")
                        BulletRow(text: "This expense is above your historical average")
                        BulletRow(text: "We classified \"Delivery\" as Regret based on your profile")
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 16)
                
                // 5. Buttons
                VStack(spacing: 12) {
                    Button {
                        // Report issue
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle")
                            Text("Report issue")
                            Spacer()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                    }
                    
                    Button {
                        // Add note
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text")
                            Text("Add note")
                            Spacer()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .padding(.top)
            .background(Color(.systemGray6))
        }
        .navigationBarBackButtonHidden(false)
    }
}

// Helper bullet list
struct BulletRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.blue)
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Previews
#Preview("MovementsView") {
    MovementsView()
}

#Preview("MovementDetailView") {
    NavigationStack {
        MovementDetailView(
            movement: Movement(
                emoji: "🍔",
                name: "Uber Eats",
                description: "Burger order with delivery",
                date: "Today 12:24",
                place: "Downtown",
                amount: "$160",
                categoryText: "Delivery",
                classification: "Regret"
            )
        )
    }
}


//
//  MetaView.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/26/25.
//

import SwiftUI

struct MetaView: View {
    @State private var metrics: CoachMetrics? = nil
    @State private var opportunities: [Opportunity] = []
    @State private var currentGoal: Goal? = nil  // Add this to store current goal details
    @State private var existingGoals: [Goal] = []
    @State private var isLoadingGoals = false
    let userId: Int = 1  // Cambiar según usuario
    
    // MARK: - Computed Properties for Goal Progress
    private var daysRemaining: Int {
        if let goal = currentGoal,
           let startDate = dateFromString(goal.start_date),
           let endDate = dateFromString(goal.end_date) {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.day], from: now, to: endDate)
            return max(0, components.day ?? 0)
        }
        // Fallback to assumption
        return max(0, 30 - 7)
    }
    
    private var suggestedDailyAmount: Int {
        if let goal = currentGoal {
            let remaining = goal.goal_amount * (1 - Double(metrics?.progress ?? 0))
            return Int(remaining / Double(max(1, daysRemaining)))
        }
        // Fallback calculation
        let remaining = (metrics?.metaSemanal ?? 0) * (1 - (metrics?.progress ?? 0))
        return Int(remaining / Double(max(1, daysRemaining)))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if let goalName = metrics?.goalName {
                        goalProgressSection(goalName: goalName)
                    }
                    savingsGoalCard
                }
                .padding(.horizontal, 16)
                .onAppear {
                    fetchMetrics()
                    fetchOpportunities()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Metas")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: NavigationLink(destination: CrearMetaView()) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            })
        }
    }
    
    // MARK: - Goal Progress Section
    private func goalProgressSection(goalName: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.green)
                Text("Progreso de tu meta")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Goal name and basic info
                Text(goalName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Progress Bar Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Progreso General")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(Int((metrics?.progress ?? 0) * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    // Progress bar with better styling
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, CGFloat(metrics?.progress ?? 0) * 300), height: 12)
                    }
                    .frame(width: 300, height: 12)
                    
                    // Amount progress
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ahorrado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let goal = currentGoal {
                                Text("$\(Int(goal.goal_amount * (metrics?.progress ?? 0)))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            } else {
                                Text("$\(Int((metrics?.metaSemanal ?? 0) * (metrics?.progress ?? 0)))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Meta Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let goal = currentGoal {
                                Text("$\(Int(goal.goal_amount))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            } else {
                                Text("$\(Int(metrics?.metaSemanal ?? 0))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Dates Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cronograma")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text("Inicio")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            if let goal = currentGoal,
                               let startDate = dateFromString(goal.start_date) {
                                Text(formatDate(startDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(formatDate(Date().addingTimeInterval(-7*24*60*60)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack {
                                Text("Meta")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.orange)
                            }
                            if let goal = currentGoal,
                               let endDate = dateFromString(goal.end_date) {
                                Text(formatDate(endDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(formatDate(Date().addingTimeInterval(30*24*60*60)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Days remaining
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.purple)
                        Text("Quedan \(daysRemaining) días")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("Ahorro diario sugerido: $\(suggestedDailyAmount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Cost Breakdown Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Análisis Financiero")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        if let goal = currentGoal {
                            costRow(title: "Ahorrado", amount: Int(goal.goal_amount * (metrics?.progress ?? 0)), color: .green)
                            costRow(title: "Falta por Ahorrar", amount: Int(goal.goal_amount * (1 - (metrics?.progress ?? 0))), color: .orange)
                        } else {
                            costRow(title: "Ahorro Semanal Actual", amount: Int((metrics?.metaSemanal ?? 0) * (metrics?.progress ?? 0)), color: .green)
                            costRow(title: "Falta por Ahorrar", amount: Int((metrics?.metaSemanal ?? 0) * (1 - (metrics?.progress ?? 0))), color: .orange)
                        }
                        
                        Divider()
                        
                        costRow(title: "Capacidad Semanal", amount: Int(metrics?.capSemanal ?? 0), color: .blue)
                        costRow(title: "Meta Semanal", amount: Int(metrics?.metaSemanal ?? 0), color: .purple)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Tips section (keep existing but improve styling)
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 Tips para alcanzar tu meta")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(opportunities.filter { $0.title.contains(goalName) }.prefix(3)) { opp in
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(opp.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(opp.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(.systemYellow).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color.green.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Savings Goal Card
    private var savingsGoalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Meta semanal de ahorro")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int((metrics?.progress ?? 0) * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Objetivo: $\(Int(metrics?.metaSemanal ?? 0))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Faltan $\(Int((metrics?.metaSemanal ?? 0) * (1 - (metrics?.progress ?? 0))))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: metrics?.progress ?? 0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func costRow(title: String, amount: Int, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("$\(amount)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Networking
    private func fetchMetrics() {
        guard let url = URL(string: "https://unitycampus.onrender.com/coach/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(CoachMetrics.self, from: data) {
                    DispatchQueue.main.async {
                        self.metrics = decoded
                        self.fetchCurrentGoal() // Fetch goal after metrics are loaded
                    }
                }
            }
        }.resume()
    }
    
    private func fetchOpportunities() {
        guard let url = URL(string: "https://unitycampus.onrender.com/coach/\(userId)/opportunities") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([String: [Opportunity]].self, from: data),
                   let opps = decoded["opportunities"] {
                    DispatchQueue.main.async {
                        self.opportunities = opps
                    }
                }
            }
        }.resume()
    }
    
    private func fetchCurrentGoal() {
        // This is a mock implementation. Replace with your actual endpoint
        // You might need to create an endpoint to get the current goal for a user
        // For now, we'll simulate having a goal based on the metrics goalName
        if let goalName = metrics?.goalName {
            // Create a mock goal based on the metrics data
            let mockGoal = Goal(
                nombre_meta: goalName,
                descripcion: "Meta generada automáticamente",
                goal_amount: metrics?.metaSemanal ?? 1000,
                tipo: "ahorro",
                start_date: DateFormatter.yyyyMMdd.string(from: Date().addingTimeInterval(-7*24*60*60)),
                end_date: DateFormatter.yyyyMMdd.string(from: Date().addingTimeInterval(30*24*60*60))
            )
            DispatchQueue.main.async {
                self.currentGoal = mockGoal
            }
        }
    }
}

#Preview {
    MetaView()
}

// MARK: - Extensions
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

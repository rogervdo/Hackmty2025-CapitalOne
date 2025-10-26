//
//  CoachView.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI
import Charts

struct Opportunity: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let description: String
    let primaryAction: String
    let secondaryAction: String?
}

struct CoachMetrics: Decodable {
    let necesarios: Double
    let innecesarios: Double
    let capSemanal: Double
    let metaSemanal: Double
    let progress: Double
    let unsortedTransactions: Int
    let impactoTotal: Double
}

struct CoachView: View {
    @State private var metrics: CoachMetrics? = nil
    @State private var opportunities: [Opportunity] = []
    let userId: Int = 1  // Cambiar según usuario

    var total: Double {
        (metrics?.necesarios ?? 0) + (metrics?.innecesarios ?? 0)
    }
    
    var necesarioPercentage: Double {
        guard total > 0 else { return 0 }
        return (metrics?.necesarios ?? 0) / total
    }
    
    var innecesarioPercentage: Double {
        guard total > 0 else { return 0 }
        return (metrics?.innecesarios ?? 0) / total
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    headerSection
                    spendingOverviewCard
                    unsortedTransactionsCard
                    savingsGoalCard
                    opportunitiesSection
                    totalImpactCard
                }
                .padding(.horizontal, 16)
                .onAppear {
                    fetchMetrics()
                    fetchOpportunities()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.white)
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Coach Financiero")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Tu semana en números")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // MARK: - Spending Overview Card
    private var spendingOverviewCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                metricColumn(title: "Necesarios", amount: metrics?.necesarios ?? 0, color: .primary)
                metricColumn(title: "Innecesarios", amount: metrics?.innecesarios ?? 0, color: .red)
                metricColumn(title: "Cap semanal", amount: metrics?.capSemanal ?? 0, color: .primary)
            }
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: necesarioPercentage)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .trim(from: necesarioPercentage, to: 1)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(total))")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                
                HStack(spacing: 32) {
                    legendItem(color: .blue, label: "Necesario", percentage: Int(necesarioPercentage * 100))
                    legendItem(color: .red, label: "Innecesario", percentage: Int(innecesarioPercentage * 100))
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
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
    
    // MARK: - Unsorted Transactions Card
    private var unsortedTransactionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "target")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎯 Quick Challenge")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Complete \(metrics?.unsortedTransactions ?? 0) swipes to unlock insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color.orange.opacity(0.02)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // MARK: - Opportunities Section
    private var opportunitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.orange)
                Text("Oportunidades de ahorro")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                ForEach(opportunities) { opp in
                    opportunityCard(
                        title: opp.title,
                        description: opp.description,
                        primaryAction: opp.primaryAction,
                        secondaryAction: opp.secondaryAction
                    )
                }
            }
        }
    }
    
    // MARK: - Total Impact Card
    private var totalImpactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.white)
                Text("Impacto total")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text("Aplicando las 3 sugerencias principales")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            HStack(alignment: .bottom, spacing: 4) {
                Text("+$\(Int(metrics?.impactoTotal ?? 0))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("/ semana")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // MARK: - Helper Views
    private func metricColumn(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("$\(Int(amount))")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func legendItem(color: Color, label: String, percentage: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(percentage)%")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
    
    private func opportunityCard(title: String, description: String, primaryAction: String, secondaryAction: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline).fontWeight(.semibold)
            Text(description).font(.subheadline).foregroundColor(.secondary).lineLimit(3)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    // MARK: - Networking
    private func fetchMetrics() {
        guard let url = URL(string: "https://unitycampus.onrender.com/coach/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(CoachMetrics.self, from: data) {
                    DispatchQueue.main.async {
                        self.metrics = decoded
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
}

#Preview {
    CoachView()
}

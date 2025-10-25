//
//  CoachView.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/25/25.
//

import SwiftUI
import Charts

struct CoachView: View {
    // Mock data for demonstration
    @State private var necesarios: Double = 980
    @State private var innecesarios: Double = 1240
    @State private var capSemanal: Double = 1000
    @State private var metaSemanal: Double = 1800
    @State private var progress: Double = 0.37
    @State private var impactoTotal: Double = 614
    @State private var unsortedTransactions: Int = 6
    
    var total: Double {
        necesarios + innecesarios
    }
    
    var necesarioPercentage: Double {
        necesarios / total
    }
    
    var innecesarioPercentage: Double {
        innecesarios / total
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Spending Overview Card
                    spendingOverviewCard
                    
                    // Unsorted Transactions Card
                    unsortedTransactionsCard
                    
                    // Savings Goal Card
                    savingsGoalCard
                    
                    // Opportunities Section
                    opportunitiesSection
                    
                    // Total Impact Card
                    totalImpactCard
                }
                .padding(.horizontal, 16)
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
            // Top metrics
            HStack(spacing: 0) {
                metricColumn(title: "Necesarios", amount: necesarios, color: .primary)
                metricColumn(title: "Innecesarios", amount: innecesarios, color: .red)
                metricColumn(title: "Cap semanal", amount: capSemanal, color: .primary)
            }
            
            // Donut Chart
            VStack(spacing: 16) {
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 120, height: 120)
                    
                    // Necessary expenses arc (blue)
                    Circle()
                        .trim(from: 0, to: necesarioPercentage)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    // Unnecessary expenses arc (red)
                    Circle()
                        .trim(from: necesarioPercentage, to: 1)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    // Center text
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(total))")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                
                // Legend
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
                
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Objetivo: $\(Int(metaSemanal))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Faltan $\(Int(metaSemanal * (1 - progress)))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ProgressView(value: progress)
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
            // Header with achievement-style messaging
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
                    
                    Text("Complete \(unsortedTransactions) swipes to unlock insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Mini progress badge
                VStack(spacing: 2) {
                    Text("\(unsortedTransactions)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Progress bar showing completion
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to Next Level")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Level up your financial insights")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 120 * (1.0 - Double(unsortedTransactions) / 10.0), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: unsortedTransactions)
                }
            }
            
            // Gamified action button
            NavigationLink(destination: SwipeView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            Text("Start Mission")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Text("Swipe to categorize • 2 min avg")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.right.2")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text("GO")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8), Color.red.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Achievement preview
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("+50 XP")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Better insights")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("🏆 Unlock rewards")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 4)
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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 8, x: 0, y: 4)
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
                opportunityCard(
                    title: "Rebasaste tu cap discrecional",
                    description: "Tus gastos innecesarios fueron de $1,240 vs tu cap de $1,000. Evita 2 deliveries esta...",
                    primaryAction: "Compensar ahora",
                    secondaryAction: "Crear tope"
                )
                
                opportunityCard(
                    title: "Cafés diarios: prueba termo 3 días",
                    description: "Compraste 5 cafés esta semana por $275. Si usas termo 3 días, ahorras $165/semana.",
                    primaryAction: "Establecer recordatorio",
                    secondaryAction: nil
                )
                
                opportunityCard(
                    title: "Streaming sin uso: pausar 30 días",
                    description: "Netflix y Spotify sin actividad en 2 semanas. Pausa temporalmente para ahorrar $258.",
                    primaryAction: "Ver suscripciones",
                    secondaryAction: nil
                )
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
                Text("+$\(Int(impactoTotal))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("/ semana")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text("Tu meta pasaría del 12 ene al 8 nov 2025 ✨")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Dismiss button (green)
            Button(action: {}) {
                Text("❌ adelantas 8 días")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(25)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {}) {
                    Text(primaryAction)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                if let secondaryAction = secondaryAction {
                    Button(action: {}) {
                        Text(secondaryAction)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
            }
            
            // "¿Por qué?" button
            Button(action: {}) {
                HStack {
                    Text("¿Por qué?")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    CoachView()
}
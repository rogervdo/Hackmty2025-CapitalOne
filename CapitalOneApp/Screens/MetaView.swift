//
//  MetaView.swift
//  CapitalOneApp
//
//  Created by Rogelio Villarreal on 10/26/25.
//
//  Updated to support multiple goals from API endpoint /metas/{user_id}
//  Uses GoalFromAPI model to avoid conflicts with existing Goal model in CrearMetaView
//  Integrates with existing CoachMetrics and Opportunity models from CoachView

import SwiftUI

// MARK: - Data Models for API Response
struct MetasResponse: Decodable {
    let metas: [GoalFromAPI]
}

struct GoalFromAPI: Identifiable, Decodable {
    let id: Int
    let nombre_meta: String
    let descripcion: String
    let goal_amount: Double
    let tipo: String
    let start_date: String
    let end_date: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "idMeta"
        case nombre_meta, descripcion, goal_amount, tipo, start_date, end_date
    }
}

struct GoalWithMetrics: Identifiable {
    let id = UUID()
    let goal: GoalFromAPI
    let metrics: CoachMetrics
    let opportunities: [Opportunity]
    
    // Computed properties for this specific goal
    var daysRemaining: Int {
        if let startDate = dateFromString(goal.start_date),
           let endDate = dateFromString(goal.end_date) {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.day], from: now, to: endDate)
            return max(0, components.day ?? 0)
        }
        return max(0, 30 - 7)
    }
    
    var suggestedDailyAmount: Int {
        let remaining = goal.goal_amount * (1 - metrics.progress)
        return Int(remaining / Double(max(1, daysRemaining)))
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

struct MetaView: View {
    @State private var goalsWithMetrics: [GoalWithMetrics] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var expandedGoals: Set<Int> = [] // Track which goals are expanded
    let userId: Int = 1  // Cambiar según usuario
    

    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading goals...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if goalsWithMetrics.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "target")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("You dont have active goals")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text("Create your first goal to start saving towards")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(destination: CrearMetaView()) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Goal")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        // Display all goals
                        ForEach(goalsWithMetrics) { goalWithMetrics in
                            goalProgressSection(goalWithMetrics: goalWithMetrics)
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.horizontal, 16)
                .onAppear {
                    fetchGoalsAndMetrics()
                }
                .refreshable {
                    await refreshData()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My goals")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: NavigationLink(destination: CrearMetaView()) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            })
        }
    }
    
    // MARK: - Goal Progress Section
    private func goalProgressSection(goalWithMetrics: GoalWithMetrics) -> some View {
        let goal = goalWithMetrics.goal
        let metrics = goalWithMetrics.metrics
        let opportunities = goalWithMetrics.opportunities
        let isExpanded = expandedGoals.contains(goal.id)
        
        return VStack(alignment: .leading, spacing: 0) {
            // Header - Always visible
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    if isExpanded {
                        expandedGoals.remove(goal.id)
                    } else {
                        expandedGoals.insert(goal.id)
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "target")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.nombre_meta)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("$\(Int(goal.goal_amount * metrics.progress)) / $\(Int(goal.goal_amount))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("• \(Int(metrics.progress * 100))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Goal type indicator
                    Text(goal.tipo.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    
                    // Expand/Collapse chevron with rotation animation
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .medium))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Compact progress bar - Only visible when NOT expanded
            if !isExpanded {
                VStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, CGFloat(metrics.progress) * UIScreen.main.bounds.width * 0.8), height: 8)
                    }
                    
                    HStack {
                        Text("You have \(goalWithMetrics.daysRemaining) days left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("$\(goalWithMetrics.suggestedDailyAmount)/day")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.9)),
                    removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 1.1))
                ))
            }
            
            // Expanded content - Only visible when expanded
            if isExpanded {
                expandedContentView(goal: goal, metrics: metrics, opportunities: opportunities, goalWithMetrics: goalWithMetrics)
                    .clipShape(Rectangle())
                    .transition(.asymmetric(
                        insertion: .move(edge: .top)
                            .combined(with: .opacity)
                            .combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .move(edge: .top)
                            .combined(with: .opacity)
                            .combined(with: .scale(scale: 1.05, anchor: .top))
                    ))
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color.green.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Expanded Content View
    @ViewBuilder
    private func expandedContentView(goal: GoalFromAPI, metrics: CoachMetrics, opportunities: [Opportunity], goalWithMetrics: GoalWithMetrics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Basic info section
            if !goal.descripcion.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.descripcion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                }
            }
            
            // Progress Bar Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("General Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(Int(metrics.progress * 100))%")
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
                        .frame(width: max(0, CGFloat(metrics.progress) * 300), height: 12)
                }
                .frame(width: 300, height: 12)
                
                // Amount progress
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(goal.goal_amount * metrics.progress))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(goal.goal_amount))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Dates Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Cronogram")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Start")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        if let startDate = dateFromString(goal.start_date) {
                            Text(formatDate(startDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack {
                            Text("Goal")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "flag.checkered")
                                .foregroundColor(.orange)
                        }
                        if let endDate = dateFromString(goal.end_date) {
                            Text(formatDate(endDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Days remaining
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.purple)
                    Text("There are \(goalWithMetrics.daysRemaining) days remaining")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Daily suggested savings: $\(goalWithMetrics.suggestedDailyAmount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Cost Breakdown Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Financial analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 8) {
                    costRow(title: "Saved", amount: Int(goal.goal_amount * metrics.progress), color: .green)
                    costRow(title: "Left to save", amount: Int(goal.goal_amount * (1 - metrics.progress)), color: .orange)
                    
                    Divider()
                    
                    costRow(title: "Weekly Capacity", amount: Int(metrics.capSemanal), color: .blue)
                    costRow(title: "Weekly goal", amount: Int(metrics.metaSemanal), color: .purple)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Tips section
            if !opportunities.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 Tips to reach your goal")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(opportunities.prefix(3)) { opp in
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
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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
    private func fetchGoalsAndMetrics() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await fetchAllGoals()
        }
    }
    
    @MainActor
    private func refreshData() async {
        await fetchAllGoals()
    }
    
    private func fetchAllGoals() async {
        do {
            // Fetch all goals for the user from the API
            let goals = await fetchUserGoalsFromAPI()
            
            // Then fetch metrics and opportunities for each goal
            var goalsWithMetricsArray: [GoalWithMetrics] = []
            
            for goal in goals {
                let metrics = await fetchMetricsForGoal(goalId: goal.nombre_meta)
                let opportunities = await fetchOpportunitiesForGoal(goalId: goal.nombre_meta)
                
                let goalWithMetrics = GoalWithMetrics(
                    goal: goal,
                    metrics: metrics,
                    opportunities: opportunities
                )
                goalsWithMetricsArray.append(goalWithMetrics)
            }
            
            await MainActor.run {
                self.goalsWithMetrics = goalsWithMetricsArray
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al cargar las metas: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func fetchUserGoalsFromAPI() async -> [GoalFromAPI] {
        return await withCheckedContinuation { continuation in
            guard let url = URL(string: "https://unitycampus.onrender.com/metas/\(userId)") else {
                print("❌ Invalid URL for goals endpoint")
                continuation.resume(returning: [])
                return
            }
            
            print("📡 Fetching goals from: \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode != 200 {
                        print("❌ HTTP Error: \(httpResponse.statusCode)")
                        continuation.resume(returning: [])
                        return
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    continuation.resume(returning: [])
                    return
                }
                
                // Log the raw JSON for debugging (first 500 chars to avoid flooding logs)
                if let jsonString = String(data: data, encoding: .utf8) {
                    let preview = String(jsonString.prefix(500))
                    print("📋 Raw JSON response preview: \(preview)")
                    if jsonString.count > 500 {
                        print("📋 ... (truncated, total length: \(jsonString.count) chars)")
                    }
                }
                
                do {
                    let decoded = try JSONDecoder().decode(MetasResponse.self, from: data)
                    print("✅ Successfully decoded \(decoded.metas.count) goals")
                    
                    // Log goal details for debugging
                    for goal in decoded.metas {
                        print("📋 Goal: \(goal.nombre_meta) - $\(goal.goal_amount) (\(goal.tipo))")
                    }
                    
                    continuation.resume(returning: decoded.metas)
                } catch {
                    print("❌ JSON decode error: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("❌ Missing key: \(key.stringValue) in \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("❌ Type mismatch for \(type) in \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("❌ Value not found for \(type) in \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("❌ Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("❌ Unknown decoding error: \(decodingError)")
                        }
                    }
                    continuation.resume(returning: [])
                }
            }.resume()
        }
    }
    
    private func fetchMetricsForGoal(goalId: String) async -> CoachMetrics {
        return await withCheckedContinuation { continuation in
            guard let url = URL(string: "https://unitycampus.onrender.com/coach/\(userId)") else {
                continuation.resume(returning: createMockMetrics(for: goalId))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data,
                   let decoded = try? JSONDecoder().decode(CoachMetrics.self, from: data) {
                    continuation.resume(returning: decoded)
                } else {
                    continuation.resume(returning: self.createMockMetrics(for: goalId))
                }
            }.resume()
        }
    }
    
    private func fetchOpportunitiesForGoal(goalId: String) async -> [Opportunity] {
        return await withCheckedContinuation { continuation in
            guard let url = URL(string: "https://unitycampus.onrender.com/coach/\(userId)/opportunities") else {
                continuation.resume(returning: [])
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data,
                   let decoded = try? JSONDecoder().decode([String: [Opportunity]].self, from: data),
                   let opportunities = decoded["opportunities"] {
                    // Filter opportunities that are relevant to this goal
                    let relevantOpportunities = opportunities.filter { 
                        $0.title.localizedCaseInsensitiveContains(goalId) ||
                        $0.description.localizedCaseInsensitiveContains(goalId)
                    }
                    continuation.resume(returning: relevantOpportunities)
                } else {
                    continuation.resume(returning: self.createMockOpportunities(for: goalId))
                }
            }.resume()
        }
    }
    
    private func createMockMetrics(for goalId: String) -> CoachMetrics {
        // Create different mock metrics for each goal to show variety
        let progressValues: [Double] = [0.25, 0.45, 0.70]
        let index = abs(goalId.hashValue) % progressValues.count
        
        return CoachMetrics(
            necesarios: 1500,
            innecesarios: 500,
            capSemanal: 800,
            metaSemanal: 600,
            progress: progressValues[index],
            unsortedTransactions: 5,
            impactoTotal: 200,
            goalName: goalId
        )
    }
    
    private func createMockOpportunities(for goalId: String) -> [Opportunity] {
        // For now, return empty array since Opportunity model with UUID() can't be easily mocked
        // In production, opportunities should come from the API endpoint
        return []
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

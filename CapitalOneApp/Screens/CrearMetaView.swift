import SwiftUI
import os.log

struct Goal: Decodable {
    let nombre_meta: String
    let descripcion: String
    let goal_amount: Double
    let tipo: String
    let start_date: String
    let end_date: String
}

struct CrearMetaResponse: Decodable {
    let message: String
    let meta: Goal
}

struct CrearMetaView: View {
    @State private var promptText = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var createdGoal: Goal?
    @Environment(\.dismiss) private var dismiss
    let userId: Int = 1 // Por defecto, cambiar según el usuario
    
    // Logger for debugging
    private let logger = Logger(subsystem: "com.app.metas", category: "CrearMetaView")
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Crear Nueva Meta")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Describe tu meta financiera")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $promptText)
                .frame(height: 150)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal)
            
            Text("Ejemplo: \"Quiero ahorrar $5000 para comprar una laptop en 3 meses\"")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            Button(action: crearMeta) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Crear Meta")
                }
            }
            .disabled(promptText.isEmpty || isLoading)
            .frame(maxWidth: .infinity)
            .padding()
            .background(promptText.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Nueva Meta")
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingSuccess) {
            if let goal = createdGoal {
                GoalCreatedSuccessView(goal: goal) {
                    dismiss()
                }
            }
        }
    }
    
    private func crearMeta() {
        // Log the initial button press and current state
        logger.info("🚀 CrearMeta button pressed")
        logger.info("📝 Prompt text: '\(promptText)'")
        logger.info("👤 User ID: \(userId)")
        logger.info("⏳ Current loading state: \(isLoading)")
        
        isLoading = true
        logger.info("🔄 Loading state set to true")
        
        guard let url = URL(string: "http://127.0.0.1:8000/metas") else {
            logger.error("❌ Invalid URL")
            errorMessage = "URL inválida"
            showingError = true
            isLoading = false
            return
        }
        
        logger.info("🌐 URL created successfully: \(url.absoluteString)")
        
        let parameters: [String: Any] = [
            "prompt": promptText,
            "user_id": userId
        ]
        
        logger.info("📦 Request parameters created: \(parameters)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        logger.info("🔧 HTTP request configured - Method: POST, Content-Type: application/json")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            logger.info("✅ Request body serialized successfully")
        } catch {
            logger.error("❌ Error encoding request data: \(error.localizedDescription)")
            errorMessage = "Error al codificar los datos"
            showingError = true
            isLoading = false
            return
        }
        
        logger.info("🚀 Starting URLSession data task...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            logger.info("📡 URLSession response received")
            
            DispatchQueue.main.async {
                logger.info("🔄 Back on main thread, setting loading to false")
                isLoading = false
                
                if let error = error {
                    logger.error("❌ Network error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showingError = true
                    return
                }
                
                // Log response details
                if let httpResponse = response as? HTTPURLResponse {
                    logger.info("📊 HTTP Status Code: \(httpResponse.statusCode)")
                    logger.info("📋 Response Headers: \(httpResponse.allHeaderFields)")
                }
                
                guard let data = data else {
                    logger.error("❌ No data received from server")
                    errorMessage = "No se recibieron datos"
                    showingError = true
                    return
                }
                
                logger.info("📦 Data received, size: \(data.count) bytes")
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        logger.info("📄 Raw JSON response: \(jsonString)")
                    }
                    
                    // Decode the response properly
                    let response = try JSONDecoder().decode(CrearMetaResponse.self, from: data)
                    logger.info("✅ JSON parsing successful")
                    logger.info("📋 Message: \(response.message)")
                    logger.info("📋 Goal created: \(response.meta.nombre_meta) - $\(String(format: "%.0f", response.meta.goal_amount))")
                    
                    // Store the created goal and show success view
                    createdGoal = response.meta
                    showingSuccess = true
                    logger.info("🏁 Success! Showing success view...")
                } catch {
                    logger.error("❌ JSON decoding error: \(error)")
                    logger.error("❌ Error details: \(error.localizedDescription)")
                    errorMessage = "Error al procesar la respuesta: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }.resume()
        
        logger.info("🚀 URLSession data task started")
    }
}

struct GoalCreatedSuccessView: View {
    let goal: Goal
    let onDismiss: () -> Void
    
    // Date formatters
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    private var startDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: goal.start_date)
    }
    
    private var endDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: goal.end_date)
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Success header
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("¡Meta Creada Exitosamente!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Tu nueva meta financiera ha sido configurada")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Goal details card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Detalles de tu Meta")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 16) {
                            DetailRow(
                                icon: "target",
                                title: "Nombre",
                                value: goal.nombre_meta,
                                color: .blue
                            )
                            
                            DetailRow(
                                icon: "text.alignleft",
                                title: "Descripción",
                                value: goal.descripcion,
                                color: .purple
                            )
                            
                            DetailRow(
                                icon: "dollarsign.circle.fill",
                                title: "Monto Objetivo",
                                value: currencyFormatter.string(from: NSNumber(value: goal.goal_amount)) ?? "$\(Int(goal.goal_amount))",
                                color: .green
                            )
                            
                            DetailRow(
                                icon: "tag.fill",
                                title: "Tipo",
                                value: goal.tipo.capitalized,
                                color: .orange
                            )
                            
                            DetailRow(
                                icon: "calendar",
                                title: "Fecha de Inicio",
                                value: startDate != nil ? dateFormatter.string(from: startDate!) : goal.start_date,
                                color: .mint
                            )
                            
                            DetailRow(
                                icon: "calendar.badge.checkmark",
                                title: "Fecha Límite",
                                value: endDate != nil ? dateFormatter.string(from: endDate!) : goal.end_date,
                                color: .red
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Tips section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("💡 Consejos para Alcanzar tu Meta")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            TipRow(
                                icon: "chart.line.uptrend.xyaxis",
                                tip: "Revisa tu progreso semanalmente para mantenerte en el camino correcto"
                            )
                            
                            TipRow(
                                icon: "creditcard.fill",
                                tip: "Considera automatizar tus ahorros para facilitar el proceso"
                            )
                            
                            TipRow(
                                icon: "bell.fill",
                                tip: "Configura recordatorios para mantener tu disciplina financiera"
                            )
                            
                            TipRow(
                                icon: "person.2.fill",
                                tip: "Comparte tu meta con amigos o familiares para mayor compromiso"
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBlue).opacity(0.1))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Meta Creada")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Continuar") {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct TipRow: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    CrearMetaView()
}

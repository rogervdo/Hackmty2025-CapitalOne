import SwiftUI

struct Goal: Decodable {
    let nombre_meta: String
    let descripcion: String
    let monto_objetivo: Double
    let tipo: String
    let fecha_inicio: String
    let fecha_fin: String
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
    @Environment(\.dismiss) private var dismiss
    let userId: Int = 1 // Por defecto, cambiar según el usuario
    
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
    }
    
    private func crearMeta() {
        isLoading = true
        
        guard let url = URL(string: "https://unitycampus.onrender.com/metas") else {
            errorMessage = "URL inválida"
            showingError = true
            isLoading = false
            return
        }
        
        let parameters: [String: Any] = [
            "prompt": promptText,
            "user_id": userId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            errorMessage = "Error al codificar los datos"
            showingError = true
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showingError = true
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No se recibieron datos"
                    showingError = true
                    return
                }
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("JSON recibido: \(jsonString)")  // Para debug
                    }
                    
                    // Primero intentamos parsear como diccionario
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Solo verificamos que haya una respuesta JSON válida
                        dismiss() // Dismiss the current view instead of navigating to CoachView
                    } else {
                        print("Error al procesar la respuesta JSON")
                        errorMessage = "Error al procesar la respuesta del servidor"
                        showingError = true
                    }
                } catch {
                    print("Error de decodificación: \(error)")
                    errorMessage = "Error al procesar la respuesta: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }.resume()
    }
}

#Preview {
    CrearMetaView()
}

import SwiftUI

struct PreferenciasView: View {
    @State private var selectedCoachMode: CoachMode = .relajado
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Coach Financiero Section
                coachSection
                
                // Modo del Coach
                coachModeSection
                
                // Info Section
                infoSection
                
                // Metas Activas
                metasActivasSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Coach Preferences")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personalize your experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 20)
        }
    }
    
    private var coachSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "target")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Financial Coach")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Your Coach will help your reach your goals through personalized suggestions. Adjust how you wish to recieve these recommendations.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var coachModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coach Mode")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                CoachModeRow(
                    mode: .relajado,
                    title: "Relaxed",
                    description: "Occasional suggestions, without pressure",
                    isSelected: selectedCoachMode == .relajado
                ) {
                    selectedCoachMode = .relajado
                }
                
                CoachModeRow(
                    mode: .normal,
                    title: "Normal",
                    description: "Balance between follow-ups and flexibility",
                    isSelected: selectedCoachMode == .normal
                ) {
                    selectedCoachMode = .normal
                }
                
                CoachModeRow(
                    mode: .estricto,
                    title: "Strict",
                    description: "Active monitoring and frequent suggestions",
                    isSelected: selectedCoachMode == .estricto
                ) {
                    selectedCoachMode = .estricto
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What does this mean?")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 12) {
                // Primera bullet point - cambia según el modo
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    Text(getFirstBulletPoint())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Segunda bullet point - cambia según el modo
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    Text(getSecondBulletPoint())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    Text("Puedes cambiar estas preferencias cuando quieras")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func getFirstBulletPoint() -> AttributedString {
        let baseString: String
        let boldWord: String
        
        switch selectedCoachMode {
        case .relajado:
            baseString = "In Relaxed mode, you'll recieve 1-2 suggestions per week."
            boldWord = "Relaxed"
        case .normal:
            baseString = "In Normal mode, you'll recieve 3-5 suggestions per week."
            boldWord = "Strict"
        case .estricto:
            baseString = "In Strict mode, you'll recieve 5+ suggestions per week."
            boldWord = "Strict"
        }
        
        var attributedString = AttributedString(baseString)
        
        // Set default color for the entire string
        attributedString.foregroundColor = .secondary
        
        // Find the range of the bold word and apply black color + bold weight
        if let range = attributedString.range(of: boldWord) {
            attributedString[range].font = .subheadline.bold()
            attributedString[range].foregroundColor = .primary  // This will be black in light mode
        }
        
        return attributedString
    }
    
    private func getSecondBulletPoint() -> String {
        switch selectedCoachMode {
        case .relajado:
            return "Notifications would be summarized daily"
        case .normal:
            return "Notifications would be summarized daily"
        case .estricto:
            return "Notifications would be immediate"
        }
    }
    
    private var metasActivasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your active goals")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                MetaRow(
                    title: "Spending goal",
                    subtitle: "$25,000 • 30 nov 2025",
                    status: "Active"
                )
                
                Divider()
                    .padding(.horizontal, 20)
                
                MetaRow(
                    title: "Discretional spending amount",
                    subtitle: "$1,000/semana",
                    status: "Active"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CoachModeRow: View {
    let mode: CoachMode
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MetaRow: View {
    let title: String
    let subtitle: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
            
            Text(status)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}

enum CoachMode: CaseIterable {
    case relajado
    case normal
    case estricto
}

#Preview {
    NavigationView {
        PreferenciasView()
    }
}

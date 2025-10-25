import SwiftUI
import Combine

// MARK: - Login View (SwiftUI)
struct LoginView: View {
    @State private var goToMain = false
    @State private var showAuthError = false
    @StateObject private var vm = LoginViewModel()
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @FocusState private var focused: Field?

    enum Field { case username, password }

    var body: some View {
        // si ya estamos autenticados, en lugar de hacer push navegando,
        // rendereamos directamente MainTabView y NO mostramos el login.
        if isAuthenticated || goToMain {
            MainTabView()
        } else {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Encabezados
                            Text("Sign in")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.primary)
                                .padding(.top, 8)

                            Text("Enter your credentials to continue")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 8)

                            // Usuario o correo
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username or email")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                IconTextField(
                                    placeholder: "username or email",
                                    text: $vm.username,
                                    icon: "person",
                                    keyboard: .default,
                                    contentType: .username,
                                    focused: _focused,
                                    field: .username
                                )
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                            }

                            // Contraseña
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                PasswordField(
                                    placeholder: "••••••••",
                                    text: $vm.password,
                                    focused: _focused,
                                    field: .password
                                )
                            }

                            // Recordarme + Olvidé contraseña
                            HStack(alignment: .center) {

                                Spacer()

                                Button("¿Forgot your password?") { /* noop (demo) */ }
                                    .font(.footnote.weight(.semibold))
                                    .buttonStyle(.plain)
                                    .foregroundStyle(Color.brandBlue)
                            }
                            .padding(.top, 2)

                            // Entrar
                            Button(action: {
                                Task {
                                    await vm.submit()
                                    if vm.formError == nil {
                                        isAuthenticated = true   // persist
                                        goToMain = true           // dispara cambio de vista
                                    } else {
                                        showAuthError = true
                                    }
                                }
                            }) {
                                HStack {
                                    Text("Continue")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!vm.canSubmit || vm.isLoading)
                            .padding(.top, 8)
                            .accessibilityIdentifier("login_enter_button")

                            // ❌ NavigationLink oculto eliminado
                            // NavigationLink(destination: MainTabView(), isActive: $goToMain){EmptyView()}

                            Spacer(minLength: 24)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .alert("Email or password incorrect", isPresented: $showAuthError){
                Button("OK", role: .cancel){}
            }
            .onAppear {
                vm.onSuccess = {
                    isAuthenticated = true
                    goToMain = true
                }
            }
        }
    }
}

// MARK: - ViewModel y demás quedan IGUAL

private struct DemoAuth {
    struct Cred { let user: String; let email: String?; let password: String }
    static let allowed: [Cred] = [
        .init(user: "demo",       email: "demo@hackmty.app",    password: "1234"),
        .init(user: "pablo",      email: "pablo@hackmty.app",   password: "1234"),
        .init(user: "admin",      email: "admin@bank.com",      password: "1234"),
        .init(user: "cliente123", email: "cliente123@bank.com", password: "1234")
    ]
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false

    @Published var isLoading: Bool = false
    @Published var formError: String? = nil

    var onSuccess: (() -> Void)?

    var canSubmit: Bool { usernameError == nil && passwordError == nil && !username.isEmpty && !password.isEmpty }

    var usernameError: String? {
        guard !username.isEmpty else { return nil }
        if username.contains("@") {
            let pattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
            let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
            return pred.evaluate(with: username) ? nil : "Correo inválido"
        } else {
            return username.count >= 3 ? nil : "At least 3 characters"
        }
    }

    var passwordError: String? {
        guard !password.isEmpty else { return nil }
        return password.count >= 4 ? nil : "At least 4 characters"
    }

    func submit() async {
        guard canSubmit else { return }
        isLoading = true
        formError = nil
        do {
            try await Task.sleep(nanoseconds: 600_000_000)

            let input = username.lowercased()
            let success = DemoAuth.allowed.contains { cred in
                (cred.user.lowercased() == input || cred.email?.lowercased() == input) && cred.password == password
            }

            if success {
                onSuccess?()
            } else {
                throw AuthError.invalidCredentials
            }
        } catch {
            formError = (error as? AuthError)?.localizedDescription ?? "Couldn't log in, please try again"
        }
        isLoading = false
    }

    enum AuthError: LocalizedError {
        case invalidCredentials
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Credenciales incorrectas"
            }
        }
    }
}

struct IconTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    @FocusState var focused: LoginView.Field?
    var field: LoginView.Field

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textContentType(contentType)
                .focused($focused, equals: field)
                .submitLabel(.next)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct PasswordField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState var focused: LoginView.Field?
    var field: LoginView.Field
    @State private var isSecure: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.body)
                .foregroundStyle(.secondary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($focused, equals: field)
                        .textContentType(.password)
                        .submitLabel(.go)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($focused, equals: field)
                        .textContentType(.password)
                        .submitLabel(.go)
                }
            }

            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSecure ? "Mostrar contraseña" : "Ocultar contraseña")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.brandBlue)
                    .opacity(configuration.isPressed ? 0.9 : 1)
            )
            .foregroundStyle(.white)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .imageScale(.medium)
                configuration.label
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    static let brandBlue = Color(red: 0.06, green: 0.38, blue: 1.0)
    static let border = Color(.systemGray4)
}

#Preview {
    LoginView()
}


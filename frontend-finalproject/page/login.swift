import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @AppStorage("cachedUserId") private var cachedUserId: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case username, password }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    Spacer() // ดัน VStack ลงมาให้กลางจอ

                    VStack(spacing: 25) {
                        Text("Welcome👋")
                            .font(.system(size: 34, weight: .bold))
                        
                        VStack(spacing: 16) {
                            TextField("Username", text: $username)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)

                            SecureField("Password", text: $password)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }

                        Button {
                            Task { await handleLogin() }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.indigo)
                                    .cornerRadius(12)
                            } else {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.indigo)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isLoginDisabled)

                        NavigationLink(destination: RegisterView()) {
                            Text("Don't have an account? Sign up")
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.indigo.opacity(0.1))
                                .foregroundColor(.indigo)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer() // ดัน VStack ให้ center ทั้งแนวตั้ง
                }
            }
            .navigationBarHidden(true)
        }
    }



    private var isLoginDisabled: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.count < 4 ||
        isLoading
    }

    private func handleLogin() async {
        guard !isLoginDisabled else { return }
        isLoading = true
        errorMessage = nil
        await authVM.login(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        isLoading = false

        if authVM.isLoggedIn, let userId = authVM.currentUser?.id {
            cachedUserId = userId
        } else {
            errorMessage = "Invalid username or password"
        }
    }
}

#Preview {
    LoginView()
}

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss

    enum Field { case username, password }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 34, weight: .bold))
                            Text("Join us in a few seconds")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)

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
                                .focused($focusedField, equals: .username)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }

                            SecureField("Password", text: $password)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit { Task { await signUp() } }
                        }
                        .padding(.horizontal, 24)

                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(messageHasError ? .red : .secondary)
                                .font(.footnote)
                                .padding(.horizontal, 24)
                        }

                        VStack(spacing: 12) {
                            Button {
                                Task { await signUp() }
                            } label: {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.indigo)
                                        .cornerRadius(12)
                                } else {
                                    Text("Sign Up")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.indigo)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 24)
                            .disabled(isSignUpDisabled)

                            Button("I already have an account") {
                                dismiss()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.indigo.opacity(0.1))
                            .foregroundColor(.indigo)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .tint(.indigo)
                }
            }
        }
        .tint(.indigo)
    }

    private var isSignUpDisabled: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.count < 4 ||
        isLoading
    }

    private var messageHasError: Bool {
        message.lowercased().contains("fail")
        || message.lowercased().contains("exists")
        || message.lowercased().contains("error")
    }

    private func signUp() async {
        guard !isSignUpDisabled else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await User.shared.createUser(
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            message = "Welcome, \(user.username)!"
            try? await Task.sleep(nanoseconds: 700_000_000)
            dismiss()
        } catch {
            message = "Failed to create user: \(error.localizedDescription)"
        }
    }
}

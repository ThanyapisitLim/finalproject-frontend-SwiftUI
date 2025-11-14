//
//  สogin.swift
//  frontend-finalproject
//
//  Created by tagter on 11/11/2568 BE.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authVM: AuthViewModel   // ใช้ ViewModel จาก App หลัก
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    Text("Welcome👋")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    VStack(spacing: 15) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }

                    Button {
                        Task {
                            await handleLogin()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 200, height: 45)
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Login")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(width: 200, height: 45)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }

                    NavigationLink(destination: RegisterView()) {
                        Text("Don't have an account? Sign up")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Function
    private func handleLogin() async {
        isLoading = true
        errorMessage = nil
        await authVM.login(username: username, password: password)
        isLoading = false

        if !authVM.isLoggedIn {
            errorMessage = "Invalid username or password"
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

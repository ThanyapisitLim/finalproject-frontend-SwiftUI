//
//  register.swift
//  frontend-finalproject
//
//  Created by tagter on 11/11/2568 BE.
//

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Sign Up") {
                Task {
                    if let user = try? await User.shared.createUser(username: username, password: password) {
                        message = "User created: \(user.username)"
                    } else {
                        message = "Failed to create user"
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Text(message)
                .foregroundColor(.gray)
                .font(.footnote)
        }
    }
}


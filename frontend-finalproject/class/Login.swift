//
//  Login.swift
//  frontend-finalproject
//
//  Created by tagter on 11/11/2568 BE.
//

import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User.UserModel? = nil

    //Check
    init() {
        checkLoginStatus()
    }

    //Login
    func login(username: String, password: String) async {
        do {
            if let user = try await User.shared.loginUser(username: username, password: password) {
                currentUser = user
                isLoggedIn = true
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                print("Login success:", user.username)
            } else {
                isLoggedIn = false
                print("Login failed: invalid credentials")
            }
        } catch {
            print("Login error:", error)
            isLoggedIn = false
        }
    }

    //Logout
    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }

    //Check Login
    func checkLoginStatus() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}

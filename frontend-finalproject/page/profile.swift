//
//  profile.swift
//  frontend-finalproject
//
//  Created by tagter on 29/10/2568 BE.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 30) {

            // HEADER AREA
            VStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .overlay(
                        Text(initials(User.shared.currentUsername()))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 6)

                Text(User.shared.currentUsername() ?? "Guest")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 60)

            Spacer()

            // LOGOUT BUTTON
            Button(action: {
                authVM.logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
    }

    // Generate initials like "T"
    func initials(_ username: String?) -> String {
        guard let name = username, !name.isEmpty else { return "?" }
        return String(name.prefix(1)).uppercased()
    }
}

//
//  profile.swift
//  frontend-finalproject
//
//  Created by tagter on 29/10/2568 BE.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var authVM: AuthViewModel   // ดึงจาก EnvironmentObject

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Profile Page")
                .font(.title2)
                .padding(.top, 40)

            Spacer()

            Button(action: {
                authVM.logout()
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}



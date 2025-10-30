//
//  LoadingView.swift
//  frontend-finalproject
//

import SwiftUI

struct LoadingView: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            // Background to cover entire screen
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundColor(.indigo)
                    .scaleEffect(appear ? 1.0 : 0.92)
                    .opacity(appear ? 1 : 0)

            }
        }
    }
}
#Preview {
    LoadingView()
}

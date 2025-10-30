//
//  LoadingView.swift
//  frontend-finalproject
//

import SwiftUI

struct LoadingView: View {
    var title: String = "Loading…"

    var body: some View {
        ZStack {
            // Background to cover entire screen
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.2)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

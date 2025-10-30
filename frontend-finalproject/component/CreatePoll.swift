//
//  CreatePoll.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import SwiftUI

struct FloatingActionButton: View {
    var action: () -> Void
    var size: CGFloat = 56
    var iconSize: CGFloat = 24
    var backgroundColor: Color = .indigo
    var foregroundColor: Color = .white
    var shadowColor: Color = .black.opacity(0.3)

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: shadowColor, radius: 4, x: 0, y: 4)
                .contentShape(Circle())
        }
        .accessibilityLabel("Create")
    }
}

struct CreatePollButton: View {
    var action: () -> Void
    var horizontalPadding: CGFloat = 24
    var verticalPadding: CGFloat = 32

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(action: action)
                    .padding(.trailing, horizontalPadding)
                    .padding(.bottom, verticalPadding)
            }
        }
        .allowsHitTesting(true)
    }
}

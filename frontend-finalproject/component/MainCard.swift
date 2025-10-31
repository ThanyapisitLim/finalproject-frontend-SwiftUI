//
//  mainCard.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import SwiftUI

struct MainCard: View {
    var imageName: String
    var poll: PollModel

    // ใช้ PollModel สำหรับการเลือกแทน Poll (ซึ่งเป็น View)
    @Binding var selectedPoll: PollModel?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.indigo.opacity(0.1))
                    .frame(width: 70, height: 70)
                Image(systemName: imageName)
                    .font(.system(size: 28))
                    .foregroundColor(.indigo)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(poll.question)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text("\(poll.options.count) options")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        // 🖱️ Tap gesture เพื่อเลือก poll
        .onTapGesture {
            selectedPoll = poll
        }
    }
}


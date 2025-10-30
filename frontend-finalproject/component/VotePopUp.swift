//
//  pollPopUp.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import SwiftUI

struct PollPopupVote: View {
    @Environment(\.dismiss) var dismiss
    let poll: PollModel
    @State private var selectedOption: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text(poll.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()

            // Options เป็นปุ่ม
            ForEach(poll.options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.indigo)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedOption == option ? Color.indigo : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            Button(action: {
                // ส่งผลการโหวตไป API หรือทำอะไรก็ได้
                print("Voted for:", selectedOption ?? "none")
                dismiss()
            }) {
                Text("Vote")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedOption != nil ? Color.indigo : Color.gray)
                    .cornerRadius(14)
            }
            .disabled(selectedOption == nil)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}


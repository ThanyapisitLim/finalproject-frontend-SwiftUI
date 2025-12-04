//
//  VoteRowView.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 16/11/2568 BE.
//
import SwiftUI
struct VoteRowView: View {
    let vote: Vote.VoteModel

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.indigo.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.indigo)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(vote.question?.isEmpty == false ? vote.question! : "Poll: \(vote.pollId)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text("Selected: \(vote.selectedOption)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(Self.displayFormatter.string(from: vote.timestamp))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
        )
    }
}

//
//  pollPopUp.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import SwiftUI

struct VotePopup: View {
    @Environment(\.dismiss) private var dismiss
    let poll: Poll.PollModel
    let userId: String
    @State private var selectedOption: String? = nil
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background blur for premium feel
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()

                // Card container
                VStack(spacing: 16) {
                    HeaderView(question: poll.question)

                    // Choices list
                    OptionsListView(
                        options: poll.options,
                        selectedOption: $selectedOption
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Primary action
                    Button {
                        Task { await submitVote() }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                            }
                            Text("Vote")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((selectedOption != nil && !isSubmitting) ? Color.indigo : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(selectedOption == nil || isSubmitting)

                    // Footer
                    if let expireText = formattedExpireText() {
                        Text(expireText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal)
            }
            .navigationTitle("Vote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func formattedExpireText() -> String? {
        let iso: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()

        guard let date = iso.date(from: poll.expireAt) else { return nil }

        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return f
        }()

        return "Ends \(formatter.string(from: date))"
    }

    private func submitVote() async {
        guard let selectedOption else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            try await Vote.shared.vote(
                userId: userId,
                pollId: poll.id,
                selectedOption: selectedOption
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


private struct HeaderView: View {
    let question: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.indigo.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.indigo)
                }
                Text("Vote")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 4)
    }
}

private struct OptionsListView: View {
    let options: [String]
    @Binding var selectedOption: String?

    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                OptionRow(
                    title: option,
                    isSelected: selectedOption == option
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedOption = option
                }
            }
        }
    }
}

private struct OptionRow: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .indigo : .secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.indigo.opacity(0.5) : Color.indigo.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1)
        )
        .animation(.default, value: isSelected)
    }
}


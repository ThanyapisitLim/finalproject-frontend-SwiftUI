//
//  PollPopUp.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import SwiftUI

struct PollPopup: View {
    @Environment(\.dismiss) private var dismiss
    let poll: PollModel
    @State private var selectedOption: String? = nil
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                CardContainer {
                    HeaderView(question: poll.question)

                    OptionsListView(
                        options: poll.options,
                        selectedOption: $selectedOption
                    )

                    ErrorView(errorMessage: errorMessage)

                    PrimaryActionButton(
                        title: "Close",
                        isSubmitting: isSubmitting
                    ) {
                        Task { await submitAction() }
                    }

                    if let expireText = formattedExpireText() {
                        FooterView(text: expireText)
                    }
                }
            }
            .navigationTitle("Poll")
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

    // MARK: - Date Helpers

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private func formattedExpireText() -> String? {
        guard let date = Self.isoFormatter.date(from: poll.expireAt) else { return nil }
        return "Ends \(Self.displayDateFormatter.string(from: date))"
    }

    // MARK: - Actions

    private func submitAction() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 250_000_000)
        dismiss()
    }
}

// MARK: - Subviews

private struct BackgroundView: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
    }
}

private struct CardContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 16) {
            content
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
                    Image(systemName: "chart.bar")
                        .foregroundColor(.indigo)
                }
                Text("Poll Details")
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

private struct ErrorView: View {
    let errorMessage: String?

    var body: some View {
        if let errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PrimaryActionButton: View {
    let title: String
    let isSubmitting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isSubmitting {
                    ProgressView()
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.indigo)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSubmitting)
    }
}

private struct FooterView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

//
//  PollPopUp.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import SwiftUI

struct PollPopup: View {
    @Environment(\.dismiss) private var dismiss
    
    let poll: Poll.PollModel
    @State private var votes: [Vote.VoteModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isDeleting = false
    @State private var showConfirmDelete = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                CardContainer(isDeleting: $isDeleting, showConfirmDelete: $showConfirmDelete, deleteAction: { await delete() }) {
                    SummaryHeaderView(
                        imageName: "chart.bar.fill",
                        question: poll.question,
                        optionsCount: poll.options.count
                    )

                    if isLoading {
                        ProgressView("Loading votes…")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ResultsListView(
                            options: poll.options,
                            counts: countsByOption(),
                            total: votes.count
                        )
                    }

                    if let expireText = formattedExpireText() {
                        Text(expireText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                .disabled(isDeleting)
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
            .task {
                await loadVotes()
            }
        }
        .presentationDetents([.large])
    }

    //Date Helpers
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()


    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private func formattedExpireText() -> String? {
        if let date = Self.isoFormatter.date(from: poll.expireAt) {
            return "Ends \(Self.displayDateFormatter.string(from: date))"
        } else {
            // fallback parser (ไม่มี .000Z)
            let simpleFormatter = ISO8601DateFormatter()
            if let date = simpleFormatter.date(from: poll.expireAt) {
                return "Ends \(Self.displayDateFormatter.string(from: date))"
            } else {
                return "Invalid date format"
            }
        }
    }

    //Data
    private func loadVotes() async {
        isLoading = true
        errorMessage = nil
        do {
            votes = try await Vote.shared.fetchVotesByPoll(pollId: poll.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func countsByOption() -> [String: Int] {
        var dict: [String: Int] = [:]
        for opt in poll.options {
            dict[opt] = 0
        }
        for v in votes {
            dict[v.selectedOption, default: 0] += 1
        }
        return dict
    }
    
    private func delete() async {
        isDeleting = true
        do {
            _ = try await Poll.shared.deletePoll(pollId: poll.id)
            await MainActor.run { dismiss() }
        } catch {
            print("ลบไม่สำเร็จ: \(error)")
        }
        isDeleting = false
    }
}

//Subviews
private struct BackgroundView: View {
    var body: some View {
        Color.clear
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }
}

private struct CardContainer<Content: View>: View {
    @Binding var isDeleting: Bool
    @Binding var showConfirmDelete: Bool
    let deleteAction: () async -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 16) {
            content
            Button {
                showConfirmDelete = true
            } label: {
                Group {
                    if isDeleting {
                        ProgressView()
                    } else {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(8)
            }
            .alert("ยืนยันการลบ?", isPresented: $showConfirmDelete) {
                Button("ลบ", role: .destructive) {
                    Task { await deleteAction() }
                }
                Button("ยกเลิก", role: .cancel) {}
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
}

private struct SummaryHeaderView: View {
    let imageName: String
    let question: String
    let optionsCount: Int

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
                Text(question)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text("\(optionsCount) options")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
    }
}

private struct ResultsListView: View {
    let options: [String]
    let counts: [String: Int]
    let total: Int

    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                let count = counts[option] ?? 0
                let percent = total > 0 ? Double(count) / Double(total) : 0

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(option)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(count) (\(Int((percent * 100).rounded()))%)")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    GeometryReader { geo in
                        // Deduct inner paddings if any; here we keep a small inset to match visuals
                        let available = geo.size.width
                        let barWidth = max(0, CGFloat(percent) * available)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.indigo)
                                .frame(width: barWidth, height: 10)
                                .animation(.easeInOut(duration: 0.25), value: percent)
                        }
                    }
                    .frame(height: 10) // Fix height; GeometryReader will expand vertically otherwise
                }
                .padding(.vertical, 6)
            }
        }
    }
    
}

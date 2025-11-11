//
//  home.swift
//  frontend-finalproject
//
//  Created by tagter on 29/10/2568 BE.
//

import SwiftUI

struct Home: View {
    @State private var polls: [Poll.PollModel] = []
    @State private var isLoading = true
    @State private var selectedPoll: Poll.PollModel? = nil // สำหรับ modal
    // Provide a userId here to use for voting (adjust as appropriate for your app)
    private let userId = "6901c4b2217d04ec4b17bb8a"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(polls) { poll in
                        MainCard(
                            imageName: "chart.bar.fill",
                            poll: poll,
                            selectedPoll: $selectedPoll
                        )
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Polls")
            .task {
                await loadPolls()
            }
            .sheet(item: $selectedPoll) { (poll: Poll.PollModel) in
                VotePopup(poll: poll, userId: userId)
            }
        }
    }

    private func loadPolls() async {
        isLoading = true
        do {
            polls = try await Poll.shared.fetchPolls()
        } catch {
            print("❌ Fetch error:", error)
        }
        isLoading = false
    }
}


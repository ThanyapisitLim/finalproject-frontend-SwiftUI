import SwiftUI

struct PollView: View {
    let userId = "690228db03a3f45002921b9a"
    @State private var polls: [PollModel] = []
    @State private var isLoading = true
    @State private var selectedPoll: PollModel? = nil
    @State private var showCreatePoll = false

    var body: some View {
        NavigationStack {
            ZStack {
                // ScrollView สำหรับ MainCard
                ScrollView {
                    VStack(spacing: 16) {
                        if isLoading {
                            ProgressView("Loading…")
                                .padding(.top, 40)
                        }
                        ForEach(polls) { poll in
                            MainCard(
                                imageName: "chart.bar.fill",
                                pollId: poll.id,
                                question: poll.question,
                                options: poll.options,
                                selectedPoll: $selectedPoll
                            )
                        }
                        if !isLoading && polls.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.system(size: 36))
                                    .foregroundColor(.secondary)
                                Text("No polls yet")
                                    .foregroundColor(.secondary)
                                Text("Tap + to create your first poll.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.top)
                }

                // Floating "+" button using reusable component
                CreatePollButton {
                    showCreatePoll = true
                }
            }
            .navigationTitle("My Polls")
            .task {
                await loadMyPolls()
            }
            // Present vote popup when a card is tapped (optional; choose VotePopup or PollPopup)
            .sheet(item: $selectedPoll) { (poll: PollModel) in
                PollPopup(poll: poll)
            }
            // Present Create Poll form
            .sheet(isPresented: $showCreatePoll) {
                CreatePollView(userId: userId) { created in
                    // On success, prepend or refresh list
                    // Option 1: Just insert locally
                    polls.insert(created, at: 0)
                    // Option 2 (recommended): refresh from server
                    Task { await loadMyPolls() }
                }
            }
        }
    }

    private func loadMyPolls() async {
        isLoading = true
        do {
            polls = try await APIService.shared.fetchVotesByUser(userId: userId)
        } catch {
            print("❌ Fetch error:", error)
        }
        isLoading = false
    }
}

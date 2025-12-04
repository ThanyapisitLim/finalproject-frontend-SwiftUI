import SwiftUI

struct PollView: View {
    @AppStorage("cachedUserId") private var userId: String = ""
    @State private var polls: [Poll.PollModel] = []
    @State private var isLoading = true
    @State private var selectedPoll: Poll.PollModel? = nil
    @State private var showCreatePoll = false
    @State private var hasLoadedOnce = false
    
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
                                poll: poll,
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
                CreatePollButton {
                    showCreatePoll = true
                }
            }
            .task {
                if !hasLoadedOnce {
                    hasLoadedOnce = true
                    await loadMyPolls()
                }
            }
            .sheet(item: $selectedPoll) { (poll: Poll.PollModel) in
                PollPopup(poll: poll)
            }
            .sheet(isPresented: $showCreatePoll) {
                CreatePollView(userId: userId) { created in
                    polls.insert(created, at: 0)
                    Task { await loadMyPolls() }
                }
            }
            .refreshable {
                await loadMyPolls()
            }
        }
    }

    private func loadMyPolls() async {
        // 1) โหลด Cache ก่อน → แสดงทันที ไม่ต้องรอ API
        let cached = Poll.shared.loadPollsFromCache()
        if !cached.isEmpty {
            polls = cached
        }

        isLoading = true

        // 2) โหลดข้อมูลจริงจาก server
        do {
            let freshPolls = try await Poll.shared.fetchPollsByUser(userId: userId)
            polls = freshPolls // อัปเดต UI
        } catch {
            print("❌ Fetch error:", error)
        }

        isLoading = false
    }
}


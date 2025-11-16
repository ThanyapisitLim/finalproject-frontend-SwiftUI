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
    @State private var hasLoadedOnce = false
    @AppStorage("cachedUserId") private var userId: String = ""

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
                    if !isLoading && polls.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                            Text("No polls yet")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Polls")
            .task {
                if !hasLoadedOnce {
                    hasLoadedOnce = true
                    await loadPolls()
                }
            }
            .sheet(item: $selectedPoll) { (poll: Poll.PollModel) in
                VotePopup(poll: poll, userId: userId)
            }
            .refreshable{
                await loadPolls()
            }
            
        }
    }

    private func loadPolls() async {
        // 1) โหลด Cache ก่อน → แสดงทันที ไม่ต้องรอ API
        let cached = Poll.shared.loadHomePollsFromCache()
        if !cached.isEmpty {
            polls = cached
        }

        isLoading = true

        // 2) โหลดข้อมูลจริงจาก server
        do {
            let freshPolls = try await Poll.shared.fetchPolls()
            polls = freshPolls // อัปเดต UI
        } catch {
            print("❌ Fetch error:", error)
        }

        isLoading = false
    }
}


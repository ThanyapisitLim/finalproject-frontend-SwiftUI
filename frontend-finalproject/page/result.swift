import SwiftUI

struct Result: View {
    @AppStorage("cachedUserId") private var userId: String = ""
    @State private var polls: [Poll.PollModel] = []
    @State private var isLoading = true
    @State private var hasLoadedOnce = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) { // ใช้ LazyVStack เพื่อประสิทธิภาพที่ดีกว่าเมื่อมีข้อมูลเยอะ
                    if isLoading && polls.isEmpty {
                        ProgressView("Loading polls…")
                            .padding(.top, 40)
                    }
                    
                    ForEach(polls) { poll in
                        // เรียกใช้ Container ที่หุ้ม PollCardView ไว้เพื่อจัดการโหลดข้อมูลรายตัว
                        PollRowContainer(poll: poll) {
                            // Logic เมื่อลบสำเร็จ ให้ลบออกจาก Array นี้ด้วย
                            if let index = polls.firstIndex(where: { $0.id == poll.id }) {
                                polls.remove(at: index)
                            }
                        }
                    }
                    
                    if !isLoading && polls.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.top)
                .padding(.bottom, 40)
            }
            .navigationTitle("Results")
            .task {
                if !hasLoadedOnce {
                    hasLoadedOnce = true
                    await loadMyPolls()
                }
            }
            .refreshable {
                await loadMyPolls()
            }
        }
    }

    // MARK: - Data Loading
    private func loadMyPolls() async {
        // 1. โหลด Cache
        let cached = Poll.shared.loadExpiredPollsFromCache()
        if !cached.isEmpty {
            polls = cached
        }

        isLoading = true

        // 2. โหลด Server
        do {
            let freshPolls = try await Poll.shared.fetchExpirePolls()
            polls = freshPolls
        } catch {
            print("❌ Fetch polls error:", error)
        }

        isLoading = false
    }
    
    // MARK: - Subviews
    private var emptyStateView: some View {
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

// MARK: - Poll Row Container
// ตัวช่วยสำหรับโหลดข้อมูล Vote ของแต่ละ Poll เพื่อส่งให้ PollCardView
struct PollRowContainer: View {
    let poll: Poll.PollModel
    let onRemoveFromList: () -> Void // Callback เพื่อบอกแม่ว่าลบเสร็จแล้ว
    
    @State private var votes: [Vote.VoteModel] = []
    @State private var isLoadingVotes = true
    @State private var errorMessage: String?
    
    // ✅ เพิ่ม State สำหรับเปิด/ปิด Popup
    @State private var showPopup = false
    
    var body: some View {
        // นำ PollCardView ที่แยกไว้มาใส่ตรงนี้
        PollCardView(
            poll: poll,
            votes: votes,
            isLoading: isLoadingVotes,
            errorMessage: errorMessage,
        )
        // เพิ่ม onTapGesture เพื่อสั่งเปิด Popup
        .onTapGesture {
            showPopup = true
        }
        // เพิ่ม .sheet เพื่อแสดงหน้า PollPopup
        .sheet(isPresented: $showPopup) {
            // ส่งข้อมูล poll ไปยังหน้า Popup
            ResultPopup(poll: poll)
        }
        .task {
            await loadVotes()
        }
    }
    
    private func loadVotes() async {
        isLoadingVotes = true
        errorMessage = nil
        do {
            votes = try await Vote.shared.fetchVotesByPoll(pollId: poll.id)
        } catch {
            errorMessage = "Failed to load votes"
            print(error)
        }
        isLoadingVotes = false
    }
    
}

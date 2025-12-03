import SwiftUI

struct Profile: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var votes: [Vote.VoteModel] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // HEADER AREA
                VStack(spacing: 12) {
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text(initials(User.shared.currentUsername()))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 6)

                    Text(User.shared.currentUsername() ?? "Guest")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 40)

                // VOTES SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("My Votes\(votes.isEmpty ? "" : " (\(votes.count))")", systemImage: "checkmark.circle")
                            .font(.headline)
                        Spacer()
                        if isLoading {
                            ProgressView()
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.vertical, 4)
                    } else if !isLoggedIn {
                        Text("Please log in to see your votes.")
                            .foregroundStyle(.secondary)
                    } else if votes.isEmpty && !isLoading {
                        Text("No votes yet for \(User.shared.currentUsername() ?? "you").")
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(votes, id: \.id) { vote in
                                VoteRowView(vote: vote)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
                )
                .padding(.horizontal)

                // LOGOUT BUTTON
                Button(action: {
                    if let uid = User.shared.currentUser()?.id {
                        Vote.shared.clearVotesCache(userId: uid)
                    }
                    authVM.logout()
                    votes = []
                    errorMessage = nil
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: .red.opacity(0.3), radius: 6, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .task {
            await loadVotes()
        }
        .onChange(of: authVM.isLoggedIn) { _, _ in
            Task { await loadVotes(force: true) }
        }
        .refreshable {
            await loadVotes()
        }
    }

    private var isLoggedIn: Bool {
        authVM.isLoggedIn && (User.shared.currentUser() != nil)
    }

    // Generate initials like "T"
    func initials(_ username: String?) -> String {
        guard let name = username, !name.isEmpty else { return "?" }
        return String(name.prefix(1)).uppercased()
    }

    // Load votes for current user
    private func loadVotes(force: Bool = false) async {
        guard let userId = User.shared.currentUser()?.id else {
            votes = []
            print("No current user id")
            return
        }
        if isLoading && !force { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // 1) Load from cache
        let cached = Vote.shared.loadVotesFromCache(userId: userId)
        if !cached.isEmpty {
            votes = cached
            // 2) Skip network fetch entirely if we already have cache
            return
        }

        // 3) Otherwise fetch once and cache
        do {
            let fetched = try await Vote.shared.fetchVoteByUserId(userId: userId)
            votes = fetched
            Vote.shared.saveVotesToCache(fetched, userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            votes = []
            print("Fetch votes error:", error)
        }
    }
}

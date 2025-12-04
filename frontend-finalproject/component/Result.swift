import SwiftUI
struct PollCardView: View {
    // รับค่าเข้ามาจากภายนอก
    let poll: Poll.PollModel
    let votes: [Vote.VoteModel]
    let isLoading: Bool
    let errorMessage: String?
    
    @State private var isDeleting = false
    @State private var showConfirmDelete = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            SummaryHeaderView(
                imageName: "chart.bar.fill",
                question: poll.question,
                optionsCount: poll.options.count
            )
            
            // หน้าโหลด
            if isLoading {
                ProgressView("Loading votes…")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            // error
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            // โชว์กราฟ
            } else {
                Top3BarChartView(
                    options: poll.options,
                    counts: countsByOption(),
                    total: votes.count
                )
            }
            
            // วันหมดอายุ
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
    
    // MARK: - Logic Helpers
    private func countsByOption() -> [String: Int] {
        var dict: [String: Int] = [:]
        for opt in poll.options { dict[opt] = 0 }
        for v in votes { dict[v.selectedOption, default: 0] += 1 }
        return dict
    }
    
    private func formattedExpireText() -> String? {
        if let date = PollCardDateHelpers.isoFormatter.date(from: poll.expireAt) {
            return "Ends \(PollCardDateHelpers.displayDateFormatter.string(from: date))"
        } else {
            let fallback = ISO8601DateFormatter()
            if let date = fallback.date(from: poll.expireAt) {
                return "Ends \(PollCardDateHelpers.displayDateFormatter.string(from: date))"
            }
            return nil
        }
    }
}


// MARK: - Formatters
fileprivate struct PollCardDateHelpers {
    static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
}


// MARK: - Header View
fileprivate struct SummaryHeaderView: View {
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



// MARK: - 🎯 NEW: Top3 Bar Chart
fileprivate struct Top3BarChartView: View {
    let options: [String]
    let counts: [String: Int]
    let total: Int

    var top3: [(option: String, count: Int, percent: Double)] {
        let mapped = options.map { opt in
            let count = counts[opt] ?? 0
            let percent = total > 0 ? Double(count) / Double(total) : 0
            return (opt, count, percent)
        }
        .sorted { (lhs: (option: String, count: Int, percent: Double), rhs: (option: String, count: Int, percent: Double)) in
            return lhs.count > rhs.count
        }

        return Array(mapped.prefix(3))
    }

    var arrangedTop3: [(option: String, count: Int, percent: Double)] {
        var arr = top3

        while arr.count < 3 {
            arr.append((option: "", count: 0, percent: 0))
        }

        // Index: 0 = rank 1, 1 = rank 2, 2 = rank 3
        return [arr[1], arr[0], arr[2]]  // left, center, right
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 30) {
            ForEach(0..<arrangedTop3.count, id: \.self) { i in
                let item = arrangedTop3[i]

                VStack(spacing: 6) {
                    Text(item.percent > 0 ? "\(Int(item.percent * 100))%" : "-")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Rectangle()
                        .fill(i == 1 ? Color.orange : Color.indigo) // 🔥 อันดับ 1 = สีพิเศษ
                        .frame(
                            width: 32,
                            height: CGFloat(item.percent) * 160
                        )
                        .animation(.spring(), value: item.percent)

                    Text(item.option.isEmpty ? "-" : item.option)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .frame(width: 60)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}


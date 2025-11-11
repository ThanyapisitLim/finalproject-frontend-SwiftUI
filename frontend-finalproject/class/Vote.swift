//
//  VoteModel.swift
//  frontend-finalproject
//

import Foundation

class Vote {
    let myurl = "http://localhost:8000"
    static let shared = Vote()
    private init() {}
    
    //Vote Model (ใช้ตอน Fetch)
    struct VoteModel: Decodable {
        let id: String
        let userId: String
        let pollId: String
        let selectedOption: String
        let timestamp: Date
        let previousHash: String?
        let currentHash: String
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case userId, pollId, selectedOption, timestamp, previousHash, currentHash
        }
    }
    //Vote Req (ใช้ตอนสร้าง)
    struct VoteRequest: Encodable {
        let userId: String
        let pollId: String
        let selectedOption: String
    }
    
    //Fetch Votes By Poll Id
    func fetchVotesByPoll(pollId: String) async throws -> [VoteModel] {
        guard let url = URL(string: "\(myurl)/get-votes-by-poll/\(pollId)") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return (try? decoder.decode([VoteModel].self, from: data)) ?? []
    }
    //Vote Poll
    func vote(userId: String, pollId: String, selectedOption: String) async throws -> Void {
        guard let url = URL(string: "\(myurl)/vote") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = VoteRequest(userId: userId, pollId: pollId, selectedOption: selectedOption)
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "APIService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Vote failed (\(http.statusCode)): \(body)"])
        }
    }
}

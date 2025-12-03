//
//  VoteModel.swift
//  frontend-finalproject
//

import Foundation

class Vote {
    let myurl = "https://epagogic-delinda-tissual.ngrok-free.dev"
    static let shared = Vote()
    private init() {}
    
    //Vote Model (ใช้ตอน Fetch)
    struct VoteModel: Decodable, Encodable { // make Encodable for caching
        let id: String
        let userId: String
        let pollId: String
        let selectedOption: String
        let timestamp: Date
        let previousHash: String?
        let currentHash: String
        let question: String? // added to match new API response
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case userId, pollId, selectedOption, timestamp, previousHash, currentHash, question
        }
    }
    
    // Top-level response wrapper for /get-votes-by-user
    private struct VotesResponse: Decodable {
        let votes: [VoteModel]
    }

    //Vote Req
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
    
    func fetchVoteByUserId(userId: String) async throws -> [VoteModel] {
        guard let url = URL(string: "\(myurl)/get-votes-by-user/\(userId)") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let wrapped = try decoder.decode(VotesResponse.self, from: data)
        return wrapped.votes
    }
    
    // MARK: - CACHE (per user)
    private func cacheKey(for userId: String) -> String {
        "votes_cache_\(userId)"
    }
    
    func saveVotesToCache(_ votes: [VoteModel], userId: String) {
        do {
            let data = try JSONEncoder().encode(votes)
            UserDefaults.standard.set(data, forKey: cacheKey(for: userId))
        } catch {
            print("Failed to encode votes for cache:", error)
        }
    }
    
    func loadVotesFromCache(userId: String) -> [VoteModel] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey(for: userId)) else { return [] }
        do {
            // decoder without date strategy works because VoteModel is Encodable/Decodable symmetric here
            let votes = try JSONDecoder().decode([VoteModel].self, from: data)
            return votes
        } catch {
            print("Failed to decode cached votes:", error)
            return []
        }
    }
    
    func clearVotesCache(userId: String) {
        UserDefaults.standard.removeObject(forKey: cacheKey(for: userId))
    }
    
}

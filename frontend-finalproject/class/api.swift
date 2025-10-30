//
//  api.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    struct CreatePollRequest: Encodable {
        let userId: String
        let question: String
        let options: [String]
        let expireAt: String
    }
    
    struct VoteRequest: Encodable {
        let userId: String
        let pollId: String
        let selectedOption: String
    }

    func fetchPolls() async throws -> [PollModel] {
        guard let url = URL(string: "http://localhost:8000/get-polls") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let polls = try JSONDecoder().decode([PollModel].self, from: data)
        return polls
    }
    
    func fetchVotesByUser(userId: String) async throws -> [PollModel] {
        guard let url = URL(string: "http://localhost:8000/get-polls-by-user/\(userId)") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let polls = try JSONDecoder().decode([PollModel].self, from: data)
        return polls
    }

    func createPoll(userId: String, question: String, options: [String], expireAt: Date) async throws -> PollModel {
        guard let url = URL(string: "http://localhost:8000/create-poll") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let expireAtString = isoFormatter.string(from: expireAt)

        let payload = CreatePollRequest(
            userId: userId,
            question: question,
            options: options,
            expireAt: expireAtString
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "APIService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Create poll failed (\(http.statusCode)): \(body)"])
        }

        let created = try JSONDecoder().decode(PollModel.self, from: data)
        return created
    }

    func vote(userId: String, pollId: String, selectedOption: String) async throws -> Void {
        guard let url = URL(string: "http://localhost:8000/vote") else {
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

        // If backend returns JSON you care about, decode here. For now we just treat 2xx as success.
        _ = data
    }
}


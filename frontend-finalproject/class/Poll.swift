//
//  poll.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import Foundation
import SwiftUI


class Poll {
    let myurl = "http://localhost:8000"
    static let shared = Poll()
    private init() {}
    
    
    //Poll Model (ใช้ตอน Fetch)
    struct PollModel: Identifiable, Codable {
        let id: String
        let creator: String
        let question: String
        let options: [String]
        let createdAt: String
        let expireAt: String
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case creator, question, options, createdAt, expireAt
        }
    }
    //Create Poll (ใช้ตอนสร้าง)
    struct CreatePollRequest: Encodable {
        let userId: String
        let question: String
        let options: [String]
        let expireAt: String
    }
    
    //Method
    //Fetch All Poll
    func fetchPolls() async throws -> [PollModel] {
        guard let url = URL(string: "\(myurl)/get-polls") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let polls = try JSONDecoder().decode([PollModel].self, from: data)
        return polls
    }
    
    //Fetch Polls By UserId
    func fetchPollsByUser(userId: String) async throws -> [PollModel] {
        guard let url = URL(string: "\(myurl)/get-polls-by-user/\(userId)") else { return [] }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let polls = try JSONDecoder().decode([PollModel].self, from: data)
        
        // ⭐ Save to cache
        savePollsToCache(polls)
        
        return polls
    }

    //Post Create Poll
    func createPoll(userId: String, question: String, options: [String], expireAt: Date) async throws -> PollModel {
        guard let url = URL(string: "\(myurl)/create-poll") else {
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
    
    // MARK: - CACHE
    private let pollCacheKey = "cached_polls"

    func savePollsToCache(_ polls: [PollModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(polls) {
            UserDefaults.standard.set(encoded, forKey: pollCacheKey)
        }
    }

    func loadPollsFromCache() -> [PollModel] {
        if let data = UserDefaults.standard.data(forKey: pollCacheKey) {
            if let decoded = try? JSONDecoder().decode([PollModel].self, from: data) {
                return decoded
            }
        }
        return []
    }

    
}

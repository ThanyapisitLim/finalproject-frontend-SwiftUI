//
//  poll.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import Foundation
import SwiftUI


class Poll {
    let myurl = "https://epagogic-delinda-tissual.ngrok-free.dev"
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
        saveHomePollsToCache(polls)
        
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
    
    func fetchExpirePolls(userId: String) async throws -> [PollModel] {
        guard let url = URL(string: "\(myurl)/get-exp-polls/\(userId)") else { return [] }
        
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

        // Decode poll ที่สร้างสำเร็จ
        let created = try JSONDecoder().decode(PollModel.self, from: data)

        // ⭐ เพิ่มเข้าค้า Cache ของหน้า MyPoll
        var userCache = loadPollsFromCache()
        userCache.insert(created, at: 0)
        savePollsToCache(userCache)

        // ⭐ เพิ่มเข้าค้า Cache ของหน้า Home
        var homeCache = loadHomePollsFromCache()
        homeCache.insert(created, at: 0)
        saveHomePollsToCache(homeCache)
        return created
    }
    
    // MARK: - CACHE
    private let pollCacheKey = "cached_polls"
    private let homePollCacheKey = "cached_home_polls"

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
    
    func saveHomePollsToCache(_ polls: [PollModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(polls) {
            UserDefaults.standard.set(encoded, forKey: homePollCacheKey)
        }
    }

    func loadHomePollsFromCache() -> [PollModel] {
        if let data = UserDefaults.standard.data(forKey: homePollCacheKey) {
            if let decoded = try? JSONDecoder().decode([PollModel].self, from: data) {
                return decoded
            }
        }
        return []
    }
    
    func deletePoll(pollId: String) async throws -> Bool {
        guard let url = URL(string: "\(myurl)/delete-poll") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ส่ง pollId ใน body
        let body: [String: String] = ["pollId": pollId]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "APIService",
                code: http.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "Delete poll failed (\(http.statusCode)): \(bodyString)"
                ]
            )
        }

        // ลบออกจาก cache ด้วย
        var cached = loadPollsFromCache()
        cached.removeAll { $0.id == pollId }
        savePollsToCache(cached)

        var homeCached = loadHomePollsFromCache()
        homeCached.removeAll { $0.id == pollId }
        saveHomePollsToCache(homeCached)

        return true
    }
}

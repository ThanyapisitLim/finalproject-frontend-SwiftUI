//
//  VoteModel.swift
//  frontend-finalproject
//

import Foundation

struct VoteModel: Identifiable, Codable {
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

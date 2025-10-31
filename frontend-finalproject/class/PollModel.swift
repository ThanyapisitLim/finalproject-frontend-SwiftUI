//
//  poll.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 30/10/2568 BE.
//

import Foundation

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

//
//  User.swift
//  frontend-finalproject
//
//  Created by Thanyapisit on 11/11/2568 BE.
//

import Foundation

class User {
    let myurl = "http://localhost:8000"
    static let shared = User()
    private init() {}
        
    //User Model Fetch
    struct UserModel: Identifiable, Codable {
        let id: String
        let username: String
        let password: String
            
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case username
            case password
        }
    }
    //User Req (ใช้ตอนสร้าง)
    struct UserRequest: Encodable {
        let username: String
        let password: String
    }
    
    struct CreateUserResponse: Codable {
        let userId: String
    }

    //ใช้ Login
    struct LoginResponse: Codable {
        let message: String
        let userId: String
    }
    
    //Fetch User
    func fetchUser() async throws -> [UserModel] {
        guard let url = URL(string: "\(myurl)/get-user/") else { return [] }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return (try? decoder.decode([UserModel].self, from: data)) ?? []
    }
    
    //Create User
    func createUser(username: String, password: String) async throws -> UserModel {
        guard let url = URL(string: "\(myurl)/create-user") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": username, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 201:
                break // OK
            case 409:
                throw NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "Username already exists"])
            default:
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
            }
        }

        let decoder = JSONDecoder()
        let resp = try decoder.decode(CreateUserResponse.self, from: data)

        // map response → UserModel
        return UserModel(id: resp.userId, username: username, password: password)
    }


    
    func loginUser(username: String, password: String) async throws -> UserModel? {
        guard let url = URL(string: "\(myurl)/login") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": username, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let decoder = JSONDecoder()

        // Declare variables outside do/catch so they are visible in catch
        var responseData: Data?
        var urlResponse: URLResponse?

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            responseData = data
            urlResponse = response

            if let httpResp = response as? HTTPURLResponse {
                print("Status code:", httpResp.statusCode)
            }

            // Decode as LoginResponse
            let loginResp = try decoder.decode(LoginResponse.self, from: data)
            print("Login success:", loginResp)

            // Map userId → UserModel
            let user = UserModel(id: loginResp.userId, username: username, password: password)
            return user

        } catch {
            print("Login failed:", error)
            if let data = responseData, let str = String(data: data, encoding: .utf8) {
                print("Raw response:", str)
            } else if let http = urlResponse as? HTTPURLResponse {
                print("No body. HTTP status:", http.statusCode)
            }
            return nil
        }
    }
}

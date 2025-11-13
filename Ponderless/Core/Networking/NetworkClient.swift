//
//  NetworkClient.swift
//  Ponderless
//
//  Actor-based network client for API communication
//

import Foundation

/// Main network client using actor isolation for thread safety
actor NetworkClient {
    static let shared = NetworkClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var authToken: String?

    private init() {
        guard let url = URL(string: "https://api.ponderless.app/v1") else {
            fatalError("Invalid base URL")
        }
        self.baseURL = url

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        self.session = URLSession(configuration: configuration)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Authentication

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    // MARK: - Request Building

    private func buildRequest(
        for endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Data? = nil
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    // MARK: - Generic Request Methods

    func fetch<T: Decodable>(
        endpoint: Endpoint,
        type: T.Type
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        return try await perform(request: request, type: type)
    }

    func post<T: Encodable, R: Decodable>(
        endpoint: Endpoint,
        body: T,
        responseType: R.Type
    ) async throws -> R {
        let data = try encoder.encode(body)
        let request = try buildRequest(for: endpoint, method: .post, body: data)
        return try await perform(request: request, type: responseType)
    }

    func update<T: Encodable, R: Decodable>(
        endpoint: Endpoint,
        body: T,
        responseType: R.Type
    ) async throws -> R {
        let data = try encoder.encode(body)
        let request = try buildRequest(for: endpoint, method: .put, body: data)
        return try await perform(request: request, type: responseType)
    }

    func delete(endpoint: Endpoint) async throws {
        let request = try buildRequest(for: endpoint, method: .delete)
        _ = try await perform(request: request, type: EmptyResponse.self)
    }

    // MARK: - Request Execution

    private func perform<T: Decodable>(
        request: URLRequest,
        type: T.Type
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                return try decoder.decode(type, from: data)
            case 401:
                throw NetworkError.unauthorized
            case 404:
                throw NetworkError.notFound
            case 429:
                throw NetworkError.rateLimited
            case 500...599:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                if let errorResponse = try? decoder.decode(APIError.self, from: data) {
                    throw NetworkError.apiError(errorResponse)
                }
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.underlying(error)
        }
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct Endpoint {
    let path: String

    // Predefined endpoints
    static let lessons = Endpoint(path: "lessons")
    static let exercises = Endpoint(path: "exercises")
    static let reflections = Endpoint(path: "reflections")
    static let coaches = Endpoint(path: "coaches")
    static let progress = Endpoint(path: "progress")
    static let chat = Endpoint(path: "chat")

    static func lesson(id: UUID) -> Endpoint {
        Endpoint(path: "lessons/\(id)")
    }

    static func exercise(id: UUID) -> Endpoint {
        Endpoint(path: "exercises/\(id)")
    }

    static func coachChat(coachId: UUID) -> Endpoint {
        Endpoint(path: "coaches/\(coachId)/chat")
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case rateLimited
    case serverError(statusCode: Int)
    case httpError(statusCode: Int)
    case apiError(APIError)
    case underlying(Error)
    case noData
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (Code: \(code))"
        case .httpError(let code):
            return "HTTP error (Code: \(code))"
        case .apiError(let error):
            return error.message
        case .underlying(let error):
            return error.localizedDescription
        case .noData:
            return "No data received"
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}

struct APIError: Codable, Sendable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct EmptyResponse: Codable, Sendable {}
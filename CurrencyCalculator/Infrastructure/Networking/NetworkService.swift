//
//  NetworkService.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/20.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<Response>(_ endpoint: String) async throws -> Response where Response: Decodable
}

enum NetworkServiceError: LocalizedError {
    case invalidURL
    case httpCode(Int)
    case unexpectedResponse
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "URL is invalid"
        case let .httpCode(status):
            "HTTP Status Code \(status)"
        case .unexpectedResponse:
            "Response format is unexpected"
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}

///
/// An interface to interact with Open Exchange Rates API
///
final class NetworkService: NetworkServiceProtocol {
    private static let baseURL = "https://openexchangerates.org/api"
    private static let appId = "28606ef9d4454aefa07098eee808cdd5"

    func request<Response>(_ endpoint: String) async throws -> Response where Response: Decodable {
        let path = "\(endpoint)?app_id=\(NetworkService.appId)"
        guard let url = URL(string: NetworkService.baseURL + path) else {
            throw NetworkServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkServiceError.unexpectedResponse
        }

        // Check status code is success
        guard (200 ..< 300).contains(code) else {
            throw NetworkServiceError.httpCode(code)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkServiceError.unexpectedResponse
        }
    }
}

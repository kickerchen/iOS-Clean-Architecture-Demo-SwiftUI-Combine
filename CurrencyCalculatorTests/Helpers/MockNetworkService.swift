//
//  MockNetworkService.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/20.
//

@testable import CurrencyCalculator
import Foundation

final class MockNetworkService: NetworkServiceProtocol {
    // Dictionary to store mock responses for different endpoints and types
    private var mockResponses: [String: Any] = [:]
    private var mockErrors: [String: Error] = [:]

    // Track requested endpoint
    private(set) var lastRequestedEndpoint: String?

    // Set mock response for a specific endpoint and type
    func setMockResponse<T: Decodable>(_ response: T, forEndpoint endpoint: String) {
        mockResponses[endpoint] = response
    }

    // Set mock error for a specific endpoint
    func setMockError(_ error: Error, forEndpoint endpoint: String) {
        mockErrors[endpoint] = error
    }

    func request<Response>(_ endpoint: String) async throws -> Response where Response: Decodable {
        lastRequestedEndpoint = endpoint
        
        // Check if we have a mock error for this endpoint
        if let error = mockErrors[endpoint] {
            throw error
        }

        // Check if we have a mock response for this endpoint
        guard let response = mockResponses[endpoint] as? Response else {
            throw NetworkServiceError.unknown(NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No mock response set for endpoint: \(endpoint)"]))
        }

        return response
    }
}

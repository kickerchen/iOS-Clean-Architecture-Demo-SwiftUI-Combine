//
//  MockGetQuotesUseCase.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/21.
//

@testable import CurrencyCalculator
import Foundation

final class MockCalculateQuotesUseCase: CalculateQuotesUseCaseProtocol {
    var quotes: [Quote] = []
    var shouldThrowError = false
    var error: Error?

    func execute(amount: String, currency: Currency?) async throws -> [Quote] {
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return quotes
    }
}

final class MockGetCurrenciesUseCase: GetCurrenciesUseCaseProtocol {
    var currencies: [Currency] = []
    var shouldThrowError = false
    var error: Error?
    
    func execute() async throws -> [Currency] {
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return currencies
    }
}

final class MockGetQuotesUseCase: GetQuotesUseCaseProtocol {
    var quotes: [Quote] = []
    var shouldThrowError = false
    var error: Error?
    
    func execute() async throws -> [Quote] {
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return quotes
    }
}

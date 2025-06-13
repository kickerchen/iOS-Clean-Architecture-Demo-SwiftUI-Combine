//
//  MockCurrenciesRepository.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/21.
//

@testable import CurrencyCalculator
import Foundation

final class MockCurrenciesRepository: CurrenciesRepositoryProtocol {
    var currencies: [Currency] = []
    var getCurrenciesCalled = false
    var shouldThrowError = false
    var error: Error?
    
    func getCurrencies() async throws -> [Currency] {
        getCurrenciesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return currencies
    }
}

final class MockQuotesRepository: QuotesRepositoryProtocol {
    var quotes: [Quote] = []
    var getQuotesCalled = false
    var shouldThrowError = false
    var error: Error?
    
    func getQuotes() async throws -> [Quote] {
        getQuotesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return quotes
    }
}

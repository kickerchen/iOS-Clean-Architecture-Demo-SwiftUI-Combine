//
//  MockDataSources.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/20.
//

@testable import CurrencyCalculator
import Foundation

final class MockLocalDataSource: LocalDataSourceProtocol {
    var savedCurrencies: [Currency] = []
    var getCurrenciesCalled = false
    var saveCurrenciesCalled = false

    var savedQuotes: [Quote] = []
    var getQuotesCalled = false
    var saveQuotesCalled = false

    var shouldThrowError = false
    var error: Error?

    func getCurrencies() async throws -> [Currency] {
        getCurrenciesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return savedCurrencies
    }

    func saveCurrencies(_ currencies: [Currency]) async throws {
        saveCurrenciesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        savedCurrencies = currencies
    }

    func getQuotes() async throws -> [Quote] {
        getQuotesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return savedQuotes
    }

    func saveQuotes(_ quotes: [Quote]) async throws {
        saveQuotesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        savedQuotes = quotes
    }
}

final class MockRemoteDataSource: RemoteDataSourceProtocol {
    var currencies: [Currency] = []
    var fetchCurrenciesCalled = false

    var quotes: [Quote] = []
    var fetchQuotesCalled = false

    var shouldThrowError = false
    var error: Error?

    func fetchCurrencies() async throws -> [Currency] {
        fetchCurrenciesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return currencies
    }

    func fetchQuotes() async throws -> [Quote] {
        fetchQuotesCalled = true
        if shouldThrowError {
            throw error ?? NSError(domain: "Test", code: 1)
        }
        return quotes
    }
}

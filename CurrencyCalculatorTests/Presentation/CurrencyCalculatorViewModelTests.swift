//
//  CurrencyCalculatorViewModelTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/21.
//

import Combine
@testable import CurrencyCalculator
import XCTest

@MainActor
final class CurrencyCalculatorViewModelTests: XCTestCase {
    private let idJPY = "JPY"
    private let fullNameJPY = "Japanese Yen"
    private let rateJPY: Decimal = 142.108
    private let idTWD = "TWD"
    private let fullNameTWD = "New Taiwan Dollar"
    private let rateTWD: Decimal = 32.617

    private var mockCalculateQuotesUseCase: MockCalculateQuotesUseCase!
    private var mockGetCurrenciesUseCase: MockGetCurrenciesUseCase!
    private var mockGetQuotesUseCase: MockGetQuotesUseCase!
    private var sut: CurrencyCalculatorViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCalculateQuotesUseCase = MockCalculateQuotesUseCase()
        mockGetCurrenciesUseCase = MockGetCurrenciesUseCase()
        mockGetQuotesUseCase = MockGetQuotesUseCase()
        sut = CurrencyCalculatorViewModel(
            calculateQuotesUseCase: mockCalculateQuotesUseCase,
            getCurrenciesUseCase: mockGetCurrenciesUseCase,
            getQuotesUseCase: mockGetQuotesUseCase
        )
        cancellables = []
    }

    override func tearDown() {
        mockCalculateQuotesUseCase = nil
        mockGetCurrenciesUseCase = nil
        mockGetQuotesUseCase = nil
        sut = nil
        cancellables = []
        super.tearDown()
    }

    func test_fetchData_success_readyAndUpdateData() async throws {
        // Given
        let expectedCurrencies = [
            Currency(id: idJPY, fullName: fullNameJPY),
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        let expectedQuotes = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        let expectedDisplayQuotes = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockGetCurrenciesUseCase.currencies = expectedCurrencies
        mockGetQuotesUseCase.quotes = expectedQuotes
        mockCalculateQuotesUseCase.quotes = expectedDisplayQuotes

        // When
        sut.$displayQuotes
            .dropFirst()
            .sink { quotes in
                XCTAssertEqual(quotes, expectedDisplayQuotes)
            }
            .store(in: &cancellables)
        await sut.fetchData()

        // Then
        XCTAssertTrue(sut.isReady)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.selectedCurrency, expectedCurrencies.first)
        XCTAssertEqual(sut.currencies, expectedCurrencies)
    }

    func test_fetchData_getCurrenciesFailed_NotReadyAndSetError() async throws {
        // Given
        let expectedError = NSError(domain: "Test", code: 1)
        mockGetCurrenciesUseCase.shouldThrowError = true
        mockGetCurrenciesUseCase.error = expectedError

        // When
        await sut.fetchData()
        
        // Then
        XCTAssertFalse(sut.isReady)
        XCTAssertEqual(sut.error as? NSError, expectedError)
    }

    func test_fetchData_getQuotesFailed_NotReadyAndSetError() async throws {
        // Given
        let expectedError = NSError(domain: "Test", code: 1)
        mockGetQuotesUseCase.shouldThrowError = true
        mockGetQuotesUseCase.error = expectedError

        // When
        await sut.fetchData()
        
        // Then
        XCTAssertFalse(sut.isReady)
        XCTAssertEqual(sut.error as? NSError, expectedError)
    }

    func test_fetchData_calculateQuotesFailed_readyAndSetError() async throws {
        // Given
        let expectedError = NSError(domain: "Test", code: 1)
        let expectedCurrencies = [
            Currency(id: idJPY, fullName: fullNameJPY),
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        let expectedQuotes = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockGetCurrenciesUseCase.currencies = expectedCurrencies
        mockGetQuotesUseCase.quotes = expectedQuotes
        mockCalculateQuotesUseCase.shouldThrowError = true
        mockCalculateQuotesUseCase.error = expectedError

        // When
        sut.$displayQuotes
            .dropFirst()
            .sink { [weak self] _ in
                XCTAssertEqual(self?.sut.error as? NSError, expectedError)
            }
            .store(in: &cancellables)
        await sut.fetchData()
        
        // Then
        XCTAssertTrue(sut.isReady)
    }

    func test_clearError_clearPreviousError() async throws {
        // Given
        mockGetCurrenciesUseCase.shouldThrowError = true
        await sut.fetchData()
        XCTAssertNotNil(sut.error)
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.error)
    }
}

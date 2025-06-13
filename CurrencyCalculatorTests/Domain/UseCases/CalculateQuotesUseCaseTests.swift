//
//  CalculateQuotesUseCaseTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/21.
//

@testable import CurrencyCalculator
import XCTest

final class CalculateQuotesUseCaseTests: XCTestCase {
    private let idJPY = "JPY"
    private let fullNameJPY = "Japanese Yen"
    private let rateJPY: Decimal = 150.55
    private let idTWD = "TWD"
    private let fullNameTWD = "New Taiwan Dollar"
    private let rateTWD: Decimal = 30.11
    private var mockRepository: MockQuotesRepository!
    private var sut: CalculateQuotesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockQuotesRepository()
        sut = CalculateQuotesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    func test_execute_withValidInput_returnCorrectQuotes() async throws {
        // Given
        let amount = "100"
        let selectedCurrency = Currency(id: idJPY, fullName: fullNameJPY)
        let quotesBasedOnUSD = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRepository.quotes = quotesBasedOnUSD

        // When
        let result = try await sut.execute(amount: amount, currency: selectedCurrency)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, idJPY)
        XCTAssertEqual(result[0].rate, 100.0)
        XCTAssertEqual(result[1].id, idTWD)
        XCTAssertEqual(result[1].rate, 20.0)
    }

    func test_execute_withDifferentBaseCurrency_returnCorrectQuotes() async throws {
        // Given
        let amount = "100"
        let selectedCurrency = Currency(id: idTWD, fullName: fullNameTWD)
        let quotesBasedOnUSD = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRepository.quotes = quotesBasedOnUSD

        // When
        let result = try await sut.execute(amount: amount, currency: selectedCurrency)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, idJPY)
        XCTAssertEqual(result[0].rate, 500.0)
        XCTAssertEqual(result[1].id, idTWD)
        XCTAssertEqual(result[1].rate, 100.0)
    }

    func test_execute_withInvalidAmount_returnEmptyArray() async throws {
        // Given
        let amount = "invalid"
        let selectedCurrency = Currency(id: idJPY, fullName: fullNameJPY)
        let quotesBasedOnUSD = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRepository.quotes = quotesBasedOnUSD

        // When
        let result = try await sut.execute(amount: amount, currency: selectedCurrency)

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_withNilCurrency_returnEmptyArray() async throws {
        // Given
        let amount = "100"
        let quotesBasedOnUSD = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRepository.quotes = quotesBasedOnUSD

        // When
        let result = try await sut.execute(amount: amount, currency: nil)

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_withCurrencyNotMatched_throwError() async throws {
        // Given
        let amount = "100"
        let selectedCurrency = Currency(id: "PAY", fullName: "PAYPAY Dollar")
        let quotesBasedOnUSD = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRepository.quotes = quotesBasedOnUSD

        // When/Then
        do {
            _ = try await sut.execute(amount: amount, currency: selectedCurrency)
            XCTFail("Expected noRateForBaseCurrency error")
        } catch {
            XCTAssertEqual(error.localizedDescription, CalculateQuotesUseCaseError.rateUnavailableForBaseCurrency("PAY").localizedDescription)
        }
    }
}

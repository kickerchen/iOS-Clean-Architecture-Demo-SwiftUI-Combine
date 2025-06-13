//
//  GetQuotesUseCaseTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/21.
//

@testable import CurrencyCalculator
import XCTest

final class GetQuotesUseCaseTests: XCTestCase {
    private let idJPY = "JPY"
    private let rateJPY: Decimal = 142.108
    private let idTWD = "TWD"
    private let rateTWD: Decimal = 32.617
    private var mockRepository: MockQuotesRepository!
    private var sut: GetQuotesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockQuotesRepository()
        sut = GetQuotesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    func test_execute_whenRepositorySucceeds_returnQuotes() async throws {
        // Given
        let expectedQuotes = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRepository.quotes = expectedQuotes

        // When
        let quotes = try await sut.execute()

        // Then
        XCTAssertTrue(mockRepository.getQuotesCalled)
        XCTAssertEqual(quotes, expectedQuotes)        
    }

    func test_execute_whenRepositoryFails_throwError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1)
        mockRepository.shouldThrowError = true
        mockRepository.error = expectedError

        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }

        XCTAssertTrue(mockRepository.getQuotesCalled)
    }
}

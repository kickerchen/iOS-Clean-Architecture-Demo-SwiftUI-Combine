//
//  GetCurrencyUseCaseTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/21.
//

@testable import CurrencyCalculator
import XCTest

final class GetCurrenciesUseCaseTests: XCTestCase {
    private let idJPY = "JPY"
    private let fullNameJPY = "Japanese Yen"
    private let idTWD = "TWD"
    private let fullNameTWD = "New Taiwan Dollar"
    private var mockRepository: MockCurrenciesRepository!
    private var sut: GetCurrenciesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockCurrenciesRepository()
        sut = GetCurrenciesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    func test_execute_whenRepositorySucceeds_returnCurrencies() async throws {
        // Given
        let expectedCurrencies = [
            Currency(id: idJPY, fullName: fullNameJPY),
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        mockRepository.currencies = expectedCurrencies

        // When
        let currencies = try await sut.execute()

        // Then
        XCTAssertTrue(mockRepository.getCurrenciesCalled)
        XCTAssertEqual(currencies, expectedCurrencies)
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

        XCTAssertTrue(mockRepository.getCurrenciesCalled)
    }
}

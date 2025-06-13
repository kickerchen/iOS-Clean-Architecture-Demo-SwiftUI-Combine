//
//  RemoteDataSourceTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/20.
//

@testable import CurrencyCalculator
import XCTest

final class RemoteDataSourceTests: XCTestCase {
    private let idJPY = "JPY"
    private let fullNameJPY = "Japanese Yen"
    private let rateJPY: Decimal = 142.108
    private let idTWD = "TWD"
    private let fullNameTWD = "New Taiwan Dollar"
    private let rateTWD: Decimal = 32.617

    private var mockNetworkService: MockNetworkService!
    private var sut: RemoteDataSource!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = RemoteDataSource(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
        sut = nil
        super.tearDown()
    }

    func test_fetchCurrencies_whenNetworkServiceSucceeds_returnCurrencies() async throws {
        // Given
        let currenciesResponse = [
            idJPY: fullNameJPY,
            idTWD: fullNameTWD
        ]
        mockNetworkService.setMockResponse(currenciesResponse, forEndpoint: "/currencies.json")

        // When
        let currencies = try await sut.fetchCurrencies()

        // Then
        XCTAssertEqual(currencies[0].id, idJPY)
        XCTAssertEqual(currencies[0].fullName, fullNameJPY)
        XCTAssertEqual(currencies[1].id, idTWD)
        XCTAssertEqual(currencies[1].fullName, fullNameTWD)
        XCTAssertEqual(mockNetworkService.lastRequestedEndpoint, "/currencies.json")
    }

    func test_getCurrencies_whenNetworkServiceFails_throwCurrenciesError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1)
        mockNetworkService.setMockError(expectedError, forEndpoint: "/currencies.json")

        // When/Then
        do {
            _ = try await sut.fetchCurrencies()
            XCTFail("Expected error to be thrown")
        } catch let error as CurrenciesRepositoryError {
            if case let .remoteFetchFailed(error) = error {
                XCTAssertEqual(error as NSError, expectedError)
            } else {
                XCTFail("Expected remoteFetchFailed error")
            }
        } catch {
            XCTFail("Expected CurrenciesRepositoryError")
        }

        XCTAssertEqual(mockNetworkService.lastRequestedEndpoint, "/currencies.json")
    }

    func test_fetchQuotes_whenNetworkServiceSucceeds_returnQuotes() async throws {
        // Given
        let quotesResponse = LatestResponse(
            disclaimer: "test",
            license: "test",
            timestamp: Date(),
            base: "USD",
            rates: [
                idJPY: rateJPY,
                idTWD: rateTWD
            ]
        )
        mockNetworkService.setMockResponse(quotesResponse, forEndpoint: "/latest.json")

        // When
        let quotes = try await sut.fetchQuotes()

        // Then
        XCTAssertEqual(quotes[0].id, idJPY)
        XCTAssertEqual(quotes[0].rate, rateJPY)
        XCTAssertEqual(quotes[1].id, idTWD)
        XCTAssertEqual(quotes[1].rate, rateTWD)
        XCTAssertEqual(mockNetworkService.lastRequestedEndpoint, "/latest.json")
    }

    func test_getQuotes_whenNetworkServiceFails_throwQuotesError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1)
        mockNetworkService.setMockError(expectedError, forEndpoint: "/latest.json")

        // When/Then
        do {
            _ = try await sut.fetchQuotes()
            XCTFail("Expected error to be thrown")
        } catch let error as QuotesRepositoryError {
            if case let .remoteFetchFailed(error) = error {
                XCTAssertEqual(error as NSError, expectedError)
            } else {
                XCTFail("Expected remoteFetchFailed error")
            }
        } catch {
            XCTFail("Expected QuotesRepositoryError")
        }

        XCTAssertEqual(mockNetworkService.lastRequestedEndpoint, "/latest.json")
    }
}

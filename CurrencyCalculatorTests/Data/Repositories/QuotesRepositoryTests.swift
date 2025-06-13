//
//  QuotesRepositoryTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/20.
//

@testable import CurrencyCalculator
import XCTest

final class QuotesRepositoryTests: XCTestCase {
    private let idJPY = "JPY"
    private let rateJPY: Decimal = 142.108
    private let idTWD = "TWD"
    private let rateTWD: Decimal = 32.617
    private let userDefaultsSuiteName = String(describing: QuotesRepositoryTests.self)
    private var mockRemoteDataSource: MockRemoteDataSource!
    private var mockLocalDataSource: MockLocalDataSource!
    private var userDefaults: UserDefaults!
    private var sut: QuotesRepository!

    override func setUp() {
        super.setUp()

        mockRemoteDataSource = MockRemoteDataSource()
        mockLocalDataSource = MockLocalDataSource()
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)!
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)

        sut = QuotesRepository(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource,
            userDefaults: userDefaults
        )
    }

    override func tearDown() {
        mockRemoteDataSource = nil
        mockLocalDataSource = nil
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    func test_getQuotes_whenCacheIsNotExpired_returnLocalQuotes() async throws {
        // Given
        let localQuotes = [
            Quote(id: idJPY, rate: rateJPY)
        ]
        mockLocalDataSource.savedQuotes = localQuotes
        mockRemoteDataSource.quotes = [
            Quote(id: idTWD, rate: rateTWD)
        ]

        // Set last fetch timestamp to 15 minutes ago (within timeout)
        let fifteenMinutesAgo = Date().timeIntervalSince1970 - (15 * 60)
        userDefaults.set(fifteenMinutesAgo, forKey: QuotesRepository.PrefKey.lastQuotesFetchTimestamp.rawValue)

        // When
        let quotes = try await sut.getQuotes()

        // Then
        XCTAssertFalse(mockRemoteDataSource.fetchQuotesCalled)
        XCTAssertEqual(quotes, localQuotes)
    }

    func test_getQuotes_whenCacheIsExpired_fetchFromRemote() async throws {
        // Given
        let remoteQuotes = [
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockLocalDataSource.savedQuotes = [
            Quote(id: idJPY, rate: rateJPY)
        ]
        mockRemoteDataSource.quotes = remoteQuotes

        // Set last fetch timestamp to 31 minutes ago (timeout) to force remote fetch
        let thirtyOneMinutesAgo = Date().timeIntervalSince1970 - (31 * 60)
        userDefaults.set(thirtyOneMinutesAgo, forKey: QuotesRepository.PrefKey.lastQuotesFetchTimestamp.rawValue)

        // When
        let quotes = try await sut.getQuotes()

        // Then
        XCTAssertTrue(mockRemoteDataSource.fetchQuotesCalled)
        XCTAssertEqual(quotes, remoteQuotes)
    }

    func test_getQuotes_whenLocalFetchFailed_throwError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1)
        let remoteQuotes = [
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockLocalDataSource.shouldThrowError = true
        mockLocalDataSource.error = expectedError
        mockRemoteDataSource.quotes = remoteQuotes

        // Set last fetch timestamp to 15 minutes ago (within timeout)
        let fifteenMinutesAgo = Date().timeIntervalSince1970 - (15 * 60)
        userDefaults.set(fifteenMinutesAgo, forKey: QuotesRepository.PrefKey.lastQuotesFetchTimestamp.rawValue)

        // When/Then
        do {
            _ = try await sut.getQuotes()
            XCTFail("Expected QuotesRepositoryError")
        } catch {
            XCTAssertEqual(error.localizedDescription, QuotesRepositoryError.localFetchFailed(expectedError).localizedDescription)
        }

        // Then
        XCTAssertTrue(mockLocalDataSource.getQuotesCalled)
        XCTAssertFalse(mockRemoteDataSource.fetchQuotesCalled)
    }

    func test_getQuotes_whenRemoteFetchSucceed_updateTimestamp() async throws {
        // Given
        let remoteQuotes = [
            Quote(id: idTWD, rate: rateTWD)
        ]
        mockRemoteDataSource.quotes = remoteQuotes

        // Set last fetch timestamp to 31 minutes ago (timeout) to force remote fetch
        let thirtyOneMinutesAgo = Date().timeIntervalSince1970 - (31 * 60)
        userDefaults.set(thirtyOneMinutesAgo, forKey: QuotesRepository.PrefKey.lastQuotesFetchTimestamp.rawValue)

        // When
        _ = try await sut.getQuotes()

        // Then
        let updatedTimestamp = userDefaults.double(forKey: QuotesRepository.PrefKey.lastQuotesFetchTimestamp.rawValue)
        XCTAssertGreaterThan(updatedTimestamp, thirtyOneMinutesAgo)
    }

    func test_getQuotes_whenRemoteFetchFailed_returnLocalQuotes() async throws {
        // Given
        let localQuotes = [
            Quote(id: idJPY, rate: rateJPY)
        ]
        mockLocalDataSource.savedQuotes = localQuotes
        mockRemoteDataSource.shouldThrowError = true

        // Set last fetch timestamp to 31 minutes ago (expired cache) to force remote fetch
        let thirtyOneMinutesAgo = Date().timeIntervalSince1970 - (31 * 60)
        userDefaults.set(thirtyOneMinutesAgo, forKey: QuotesRepository.PrefKey.lastQuotesFetchTimestamp.rawValue)

        // When
        let quotes = try await sut.getQuotes()

        // Then
        XCTAssertTrue(mockLocalDataSource.getQuotesCalled)
        XCTAssertTrue(mockRemoteDataSource.fetchQuotesCalled)
        XCTAssertEqual(quotes, localQuotes)
    }
}

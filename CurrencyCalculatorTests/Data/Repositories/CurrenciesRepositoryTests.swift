//
//  CurrenciesRepositoryTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/20.
//

@testable import CurrencyCalculator
import XCTest

final class CurrenciesRepositoryTests: XCTestCase {
    private let idJPY = "JPY"
    private let fullNameJPY = "Japanese Yen"
    private let idTWD = "TWD"
    private let fullNameTWD = "New Taiwan Dollar"
    private let userDefaultsSuiteName = String(describing: CurrenciesRepositoryTests.self)
    private var mockRemoteDataSource: MockRemoteDataSource!
    private var mockLocalDataSource: MockLocalDataSource!
    private var userDefaults: UserDefaults!
    private var sut: CurrenciesRepository!

    override func setUp() {
        super.setUp()

        mockRemoteDataSource = MockRemoteDataSource()
        mockLocalDataSource = MockLocalDataSource()
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)!
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)

        sut = CurrenciesRepository(
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

    func test_getCurrencies_whenCacheIsNotExpired_returnLocalCurrencies() async throws {
        // Given
        let localCurrencies = [
            Currency(id: idJPY, fullName: fullNameJPY)
        ]
        mockLocalDataSource.savedCurrencies = localCurrencies
        mockRemoteDataSource.currencies = [
            Currency(id: idTWD, fullName: fullNameTWD)
        ]

        // Set last fetch timestamp to 1 hour ago (within timeout)
        let oneHourAgo = Date().timeIntervalSince1970 - (60 * 60)
        userDefaults.set(oneHourAgo, forKey: CurrenciesRepository.PrefKey.lastCurrenciesFetchTimestamp.rawValue)

        // When
        let currencies = try await sut.getCurrencies()

        // Then
        XCTAssertFalse(mockRemoteDataSource.fetchCurrenciesCalled)
        XCTAssertEqual(currencies, localCurrencies)
    }

    func test_getCurrencies_whenCacheIsExpired_fetchesFromRemote() async throws {
        // Given
        let remoteCurrencies = [
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        mockLocalDataSource.savedCurrencies = [
            Currency(id: idJPY, fullName: fullNameJPY)
        ]
        mockRemoteDataSource.currencies = remoteCurrencies

        // Set last fetch timestamp to 2 hours and 1 minute ago (timeout) to force remote fetch
        let twoHoursOneMinuteAgo = Date().timeIntervalSince1970 - (2 * 60 * 60 + 1)
        userDefaults.set(
            twoHoursOneMinuteAgo,
            forKey: CurrenciesRepository.PrefKey.lastCurrenciesFetchTimestamp.rawValue
        )

        // When
        let currencies = try await sut.getCurrencies()

        // Then
        XCTAssertTrue(mockRemoteDataSource.fetchCurrenciesCalled)
        XCTAssertEqual(currencies, remoteCurrencies)
    }

    func test_getCurrencies_whenLocalFetchFailed_throwError() async throws {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1)
        let remoteCurrencies = [
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        mockLocalDataSource.shouldThrowError = true
        mockLocalDataSource.error = expectedError
        mockRemoteDataSource.currencies = remoteCurrencies

        // Set last fetch timestamp to 1 hour ago (within timeout)
        let oneHourAgo = Date().timeIntervalSince1970 - (60 * 60)
        userDefaults.set(oneHourAgo, forKey: CurrenciesRepository.PrefKey.lastCurrenciesFetchTimestamp.rawValue)

        // When/Then
        do {
            _ = try await sut.getCurrencies()
            XCTFail("Expected CurrenciesRepositoryError")
        } catch {
            XCTAssertEqual(error.localizedDescription, CurrenciesRepositoryError.localFetchFailed(expectedError).localizedDescription)
        }

        // Then
        XCTAssertTrue(mockLocalDataSource.getCurrenciesCalled)
        XCTAssertFalse(mockRemoteDataSource.fetchCurrenciesCalled)
    }

    func test_getCurrencies_whenRemoteFetchSucceed_updateTimestamp() async throws {
        // Given
        let remoteCurrencies = [
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        mockRemoteDataSource.currencies = remoteCurrencies

        // Set last fetch timestamp to 2 hours and 1 minute ago (timeout) to force remote fetch
        let twoHoursOneMinuteAgo = Date().timeIntervalSince1970 - (2 * 60 * 60 + 1)
        userDefaults.set(
            twoHoursOneMinuteAgo,
            forKey: CurrenciesRepository.PrefKey.lastCurrenciesFetchTimestamp.rawValue
        )

        // When
        _ = try await sut.getCurrencies()

        // Then
        let updatedTimestamp = userDefaults.double(
            forKey: CurrenciesRepository.PrefKey.lastCurrenciesFetchTimestamp.rawValue
        )
        XCTAssertGreaterThan(updatedTimestamp, twoHoursOneMinuteAgo)
    }

    func test_getCurrencies_whenRemoteFetchFailed_returnLocalCurrencies() async throws {
        // Given
        let localCurrencies = [
            Currency(id: idJPY, fullName: fullNameJPY)
        ]
        mockLocalDataSource.savedCurrencies = localCurrencies
        mockRemoteDataSource.shouldThrowError = true
        mockRemoteDataSource.error = NSError(domain: "TestError", code: 1)

        // Set last fetch timestamp to 2 hours and 1 minute ago (expired cache) to force remote fetch
        let twoHoursOneMinuteAgo = Date().timeIntervalSince1970 - (2 * 60 * 60 + 1)
        userDefaults.set(
            twoHoursOneMinuteAgo,
            forKey: CurrenciesRepository.PrefKey.lastCurrenciesFetchTimestamp.rawValue
        )

        // When
        let currencies = try await sut.getCurrencies()

        // Then
        XCTAssertTrue(mockLocalDataSource.getCurrenciesCalled)
        XCTAssertTrue(mockRemoteDataSource.fetchCurrenciesCalled)
        XCTAssertEqual(currencies, localCurrencies) 
    }
}

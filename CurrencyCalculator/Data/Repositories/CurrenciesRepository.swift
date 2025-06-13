//
//  CurrenciesRepository.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

enum CurrenciesRepositoryError: LocalizedError {
    case remoteFetchFailed(Error)
    case localFetchFailed(Error)
    case saveFailed(Error)
    case noDataAvailable

    var errorDescription: String? {
        switch self {
        case let .remoteFetchFailed(error):
            "Remote fetch currencies failed: \(error.localizedDescription)"
        case let .localFetchFailed(error):
            "Local fetch currencies failed: \(error.localizedDescription)"
        case let .saveFailed(error):
            "Save currencies failed: \(error.localizedDescription)"
        case .noDataAvailable:
            "No currencies fetched"
        }
    }
}

protocol CurrenciesRepositoryProtocol {
    func getCurrencies() async throws -> [Currency]
}

///
/// The implementation of CurrenciesRepositoryProtocol to provide currencies to use cases
/// which has a cache mechanism with a timeout to save usage bewtween local and remote data sources
///
final class CurrenciesRepository: CurrenciesRepositoryProtocol {
    enum PrefKey: String {
        case lastCurrenciesFetchTimestamp
    }

    private let remoteDataSource: RemoteDataSourceProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let userDefaults: UserDefaults

    // Save currencies API calls within 2 hours of timeout although it doesn't cost the quota for free account
    private let cacheTimeout: TimeInterval = 2 * 60 * 60 // 2 hours in seconds

    private var lastFetchTimestamp: TimeInterval {
        get { userDefaults.double(forKey: PrefKey.lastCurrenciesFetchTimestamp.rawValue) }
        set { userDefaults.set(newValue, forKey: PrefKey.lastCurrenciesFetchTimestamp.rawValue) }
    }

    init(
        remoteDataSource: RemoteDataSourceProtocol = RemoteDataSource(),
        localDataSource: LocalDataSourceProtocol = LocalDataSource(
            container: CoreDataStack(store: .currencyCalculator).persistentContainer
        ),
        userDefaults: UserDefaults = .standard
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.userDefaults = userDefaults
    }

    func getCurrencies() async throws -> [Currency] {
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastFetch = currentTime - lastFetchTimestamp

        // If it has been less than 2 hours since the previous fetch, choose local storage to return
        if timeSinceLastFetch < cacheTimeout {
            do {
                let localCurrencies = try await localDataSource.getCurrencies()
                if !localCurrencies.isEmpty {
                    return localCurrencies
                }
            } catch {
                throw CurrenciesRepositoryError.localFetchFailed(error)
            }
        }

        // Try remote fetch
        do {
            // Fetch from remote first
            let currencies = try await remoteDataSource.fetchCurrencies()

            // Save to local storage and update timestamp
            do {
                try await localDataSource.saveCurrencies(currencies)
                lastFetchTimestamp = currentTime
            } catch {
                // Continue since we have the remote data
            }

            return currencies
        } catch {
            // If remote fetch failed, try local storage
            do {
                let localCurrencies = try await localDataSource.getCurrencies()
                if localCurrencies.isEmpty {
                    throw CurrenciesRepositoryError.noDataAvailable
                }
                return localCurrencies
            } catch {
                throw CurrenciesRepositoryError.localFetchFailed(error)
            }
        }
    }
}

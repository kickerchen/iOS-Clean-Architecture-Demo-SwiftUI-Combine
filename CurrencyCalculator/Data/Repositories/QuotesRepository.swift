//
//  QuotesRepository.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

enum QuotesRepositoryError: LocalizedError {
    case remoteFetchFailed(Error)
    case localFetchFailed(Error)
    case saveFailed(Error)
    case noDataAvailable

    var errorDescription: String? {
        switch self {
        case let .remoteFetchFailed(error):
            "Remote fetch quotes failed: \(error.localizedDescription)"
        case let .localFetchFailed(error):
            "Local fetch quotes failed: \(error.localizedDescription)"
        case let .saveFailed(error):
            "Save quotes failed: \(error.localizedDescription)"
        case .noDataAvailable:
            "No quotes fetched"
        }
    }
}

protocol QuotesRepositoryProtocol {
    func getQuotes() async throws -> [Quote]
}

///
/// The implementation of QuotesRepositoryProtocol to provide quotes to use cases
/// which has a cache mechanism with a timeout to save usage bewtween local and remote data sources
///
final class QuotesRepository: QuotesRepositoryProtocol {
    enum PrefKey: String {
        case lastQuotesFetchTimestamp
    }

    private let remoteDataSource: RemoteDataSourceProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let userDefaults: UserDefaults

    // In order to limit bandwidth usage, the required data can be refreshed
    // from the API no more frequently than once every 30 minutes
    private let cacheTimeout: TimeInterval = 30 * 60 // 30 minutes in seconds

    private var lastFetchTimestamp: TimeInterval {
        get { userDefaults.double(forKey: PrefKey.lastQuotesFetchTimestamp.rawValue) }
        set { userDefaults.set(newValue, forKey: PrefKey.lastQuotesFetchTimestamp.rawValue) }
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

    func getQuotes() async throws -> [Quote] {
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastFetch = currentTime - lastFetchTimestamp

        // If it has been less than 30 minutes since the previous fetch, choose local storage to return
        if timeSinceLastFetch < cacheTimeout {
            do {
                let localQuotes = try await localDataSource.getQuotes()
                if !localQuotes.isEmpty {
                    return localQuotes
                }
            } catch {
                throw QuotesRepositoryError.localFetchFailed(error)
            }
        }

        // Try remote fetch
        do {
            // Fetch from remote first
            let quotes = try await remoteDataSource.fetchQuotes()

            // Save to local storage and update timestamp
            do {
                try await localDataSource.saveQuotes(quotes)
                lastFetchTimestamp = currentTime
            } catch {
                // Continue since we have the remote data
            }

            return quotes
        } catch {
            // If remote fetch failed, try local storage
            do {
                let localQuotes = try await localDataSource.getQuotes()
                if localQuotes.isEmpty {
                    throw QuotesRepositoryError.noDataAvailable
                }
                return localQuotes
            } catch {
                throw QuotesRepositoryError.localFetchFailed(error)
            }
        }
    }
}

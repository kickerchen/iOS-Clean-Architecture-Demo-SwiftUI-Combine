//
//  RemoteDataSource.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

protocol RemoteDataSourceProtocol {
    func fetchCurrencies() async throws -> [Currency]
    func fetchQuotes() async throws -> [Quote]
}

///
/// The implementation of RemoteDataSourceProtocol to retrieve data from NetworkService
///
final class RemoteDataSource: RemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // Get a JSON list of all currency symbols available from the Open Exchange Rates API,
    // along with their full names, for use in your integration
    func fetchCurrencies() async throws -> [Currency] {
        do {
            let response: CurrenciesResponse = try await networkService.request("/currencies.json")
            return response.map { Currency(id: $0.key, fullName: $0.value) }.sorted { $0.id < $1.id }
        } catch {
            throw CurrenciesRepositoryError.remoteFetchFailed(error)
        }
    }

    // Get the latest exchange rates available from the Open Exchange Rates API
    func fetchQuotes() async throws -> [Quote] {
        do {
            let response: LatestResponse = try await networkService.request("/latest.json")
            return response.rates.map { Quote(id: $0.key, rate: $0.value) }.sorted { $0.id < $1.id }
        } catch {
            throw QuotesRepositoryError.remoteFetchFailed(error)
        }
    }
}

//
//  GetCurrencyUseCase.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

protocol GetCurrenciesUseCaseProtocol {
    func execute() async throws -> [Currency]
}

///
/// GetCurrenciesUseCase is to retrieve the currencies from currencies repository
///
final class GetCurrenciesUseCase: GetCurrenciesUseCaseProtocol {
    private let repository: CurrenciesRepositoryProtocol

    init(repository: CurrenciesRepositoryProtocol = CurrenciesRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [Currency] {
        try await repository.getCurrencies()
    }
}

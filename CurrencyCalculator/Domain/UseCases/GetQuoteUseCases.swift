//
//  GetQuoteUseCases.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

protocol GetQuotesUseCaseProtocol {
    func execute() async throws -> [Quote]
}

///
/// GetQuoesUseCase is to retrieve the quotes from quotes repository
///
final class GetQuotesUseCase: GetQuotesUseCaseProtocol {
    private let repository: QuotesRepositoryProtocol

    init(repository: QuotesRepositoryProtocol = QuotesRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [Quote] {
        try await repository.getQuotes()
    }
}

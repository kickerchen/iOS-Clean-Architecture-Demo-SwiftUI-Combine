//
//  CalculateQuotesUseCase.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/21.
//

import Foundation

enum CalculateQuotesUseCaseError: LocalizedError {
    case rateUnavailableForBaseCurrency(String)
    var errorDescription: String? {
        switch self {
        case let .rateUnavailableForBaseCurrency(currency):
            "The exchange rate for \(currency) is not available"
        }
    }
}

protocol CalculateQuotesUseCaseProtocol {
    func execute(amount: String, currency: Currency?) async throws -> [Quote]
}

///
/// CalculateQuotesUseCase is to do the conversion by dividing the rate of the selected currency
/// since changing base currency or calling conversion API are not available for free clients
///
final class CalculateQuotesUseCase: CalculateQuotesUseCaseProtocol {
    private let repository: QuotesRepositoryProtocol

    init(repository: QuotesRepositoryProtocol = QuotesRepository()) {
        self.repository = repository
    }

    func execute(amount: String, currency: Currency?) async throws -> [Quote] {
        guard let currency,
              let decimalAmount = Decimal(string: amount) else { return [] }

        let quotes = try await repository.getQuotes()
        guard let base = quotes.filter({ $0.id == currency.id }).first?.rate else {
            throw CalculateQuotesUseCaseError.rateUnavailableForBaseCurrency(currency.id)
        }
        return quotes.map {
            Quote(id: $0.id, rate: decimalAmount * ($0.rate / base))
        }.sorted { $0.id < $1.id }
    }
}

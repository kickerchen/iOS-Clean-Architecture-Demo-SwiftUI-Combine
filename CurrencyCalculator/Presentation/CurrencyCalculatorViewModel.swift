//
//  CurrencyCalculatorViewModel.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/18.
//

import Combine
import Foundation

///
/// A view model to embed the presentation logic of CurrencyCalculatorView
///
@MainActor
final class CurrencyCalculatorViewModel: ObservableObject {
    @Published private(set) var currencies: [Currency] = []
    @Published private(set) var displayQuotes: [Quote] = []
    @Published private(set) var error: Error?
    @Published private(set) var isReady: Bool = false

    @Published var amount: String = ""
    @Published var selectedCurrency: Currency?

    private let calculateQuotesUseCase: CalculateQuotesUseCaseProtocol
    private let getCurrenciesUseCase: GetCurrenciesUseCaseProtocol
    private let getQuotesUseCase: GetQuotesUseCaseProtocol

    private var quotes: [Quote] = []
    private var cancellables = Set<AnyCancellable>()

    init(
        calculateQuotesUseCase: CalculateQuotesUseCaseProtocol = CalculateQuotesUseCase(),
        getCurrenciesUseCase: GetCurrenciesUseCaseProtocol = GetCurrenciesUseCase(),
        getQuotesUseCase: GetQuotesUseCaseProtocol = GetQuotesUseCase()
    ) {
        self.calculateQuotesUseCase = calculateQuotesUseCase
        self.getCurrenciesUseCase = getCurrenciesUseCase
        self.getQuotesUseCase = getQuotesUseCase

        // Update displayQuotes whenever amount is changed or currency is selected
        Publishers.CombineLatest($amount, $selectedCurrency)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] amount, currency in
                Task { [weak self] in
                    do {
                        self?.displayQuotes = try await self?.calculateQuotesUseCase.execute(
                            amount: amount,
                            currency: currency
                        ) ?? []
                    } catch {
                        self?.error = error
                    }
                }
            }
            .store(in: &cancellables)
    }

    func clearError() {
        error = nil
    }

    func fetchData() async {
        guard !isReady else { return }
        async let getCurrencies = getCurrenciesUseCase.execute()
        async let getQuotes = getQuotesUseCase.execute()
        do {
            (currencies, quotes) = try await (getCurrencies, getQuotes)
        } catch {
            self.error = error
        }
        isReady = !currencies.isEmpty && !quotes.isEmpty
        selectedCurrency = currencies.first
    }
}

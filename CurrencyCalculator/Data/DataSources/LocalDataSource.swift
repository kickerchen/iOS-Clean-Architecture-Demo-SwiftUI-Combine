//
//  LocalDataSource.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import CoreData

protocol LocalDataSourceProtocol {
    func getCurrencies() async throws -> [Currency]
    func saveCurrencies(_ currencies: [Currency]) async throws
    func getQuotes() async throws -> [Quote]
    func saveQuotes(_ quotes: [Quote]) async throws
}

///
/// The implementation of LocalDataSourceProtocol to retrieve data from CoreData
///
final class LocalDataSource: LocalDataSourceProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func getCurrencies() async throws -> [Currency] {
        let context = container.viewContext
        return try await context.perform {
            let request = NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            let entities = try context.fetch(request)
            return entities.map { Currency(id: $0.id ?? "", fullName: $0.country ?? "") }
        }
    }

    func saveCurrencies(_ currencies: [Currency]) async throws {
        let context = container.viewContext
        try await context.perform {
            // Delete existing currencies
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
            // Save new currencies
            for currency in currencies {
                let entity = CurrencyEntity(context: context)
                entity.id = currency.id
                entity.country = currency.fullName
            }
            try context.save()
        }
    }

    func getQuotes() async throws -> [Quote] {
        let context: NSManagedObjectContext = container.viewContext
        return try await context.perform {
            let request = NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            let entities = try context.fetch(request)
            return entities.map { Quote(id: $0.id ?? "", rate: Decimal(string: $0.rate.description) ?? 0) }
        }
    }

    func saveQuotes(_ quotes: [Quote]) async throws {
        let context = container.viewContext
        try await context.perform {
            // Delete existing quotes
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "QuoteEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
            // Save new quotes
            for quote in quotes {
                let entity = QuoteEntity(context: context)
                entity.id = quote.id
                entity.rate = NSDecimalNumber(decimal: quote.rate).doubleValue
            }
            try context.save()
        }
    }
}

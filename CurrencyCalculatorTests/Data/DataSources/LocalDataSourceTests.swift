//
//  LocalDataSourceTests.swift
//  CurrencyCalculatorTests
//
//  Created by Kicker Chen on 2025/4/18.
//

import CoreData
@testable import CurrencyCalculator
import XCTest

final class LocalDataSourceTests: XCTestCase {
    private let idJPY = "JPY"
    private let fullNameJPY = "Japanese Yen"
    private let rateJPY: Decimal = 142.108
    private let idTWD = "TWD"
    private let fullNameTWD = "New Taiwan Dollar"
    private let rateTWD: Decimal = 32.617

    private var sut: LocalDataSource!
    private var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        container = CoreDataStack(store: .testCurrencyCalculator).persistentContainer
        sut = LocalDataSource(container: container)
    }

    override func tearDown() {
        sut = nil
        container = nil
        super.tearDown()
    }

    func test_saveCurrenciesToCoreData() async throws {
        // Given
        let currencies = [
            Currency(id: idJPY, fullName: fullNameJPY),
            Currency(id: idTWD, fullName: fullNameTWD)
        ]

        // When
        try await sut.saveCurrencies(currencies)

        // Then
        let context = container.viewContext
        let request = NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        let savedCurrencies = try context.fetch(request)

        XCTAssertEqual(savedCurrencies.count, 2)
        XCTAssertEqual(savedCurrencies[0].id, idJPY)
        XCTAssertEqual(savedCurrencies[0].country, fullNameJPY)
        XCTAssertEqual(savedCurrencies[1].id, idTWD)
        XCTAssertEqual(savedCurrencies[1].country, fullNameTWD)
    }

    func test_getCurrencies_returnSavedCurrencies() async throws {
        // Given
        let currencies = [
            Currency(id: idJPY, fullName: fullNameJPY),
            Currency(id: idTWD, fullName: fullNameTWD)
        ]
        try await sut.saveCurrencies(currencies)

        // When
        let savedCurrencies = try await sut.getCurrencies()

        // Then
        XCTAssertEqual(savedCurrencies.count, 2)
        XCTAssertEqual(savedCurrencies[0].id, idJPY)
        XCTAssertEqual(savedCurrencies[0].fullName, fullNameJPY)
        XCTAssertEqual(savedCurrencies[1].id, idTWD)
        XCTAssertEqual(savedCurrencies[1].fullName, fullNameTWD)
    }

    func test_getCurrencies_whenNoCurrenciesSaved_returnEmptyArray() async throws {
        // When
        let currencies = try await sut.getCurrencies()

        // Then
        XCTAssertTrue(currencies.isEmpty)
    }

    func test_saveQuotesToCoreData() async throws {
        // Given
        let quotes = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]

        // When
        try await sut.saveQuotes(quotes)

        // Then
        let context = container.viewContext
        let request = NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        let savedQuotes = try context.fetch(request)

        XCTAssertEqual(savedQuotes.count, 2)
        XCTAssertEqual(savedQuotes[0].id, idJPY)
        XCTAssertEqual(Decimal(string: savedQuotes[0].rate.description), rateJPY)
        XCTAssertEqual(savedQuotes[1].id, idTWD)
        XCTAssertEqual(Decimal(string: savedQuotes[1].rate.description), rateTWD)
    }

    func test_getQuotes_returnSavedQuotes() async throws {
        // Given
        let quotes = [
            Quote(id: idJPY, rate: rateJPY),
            Quote(id: idTWD, rate: rateTWD)
        ]
        try await sut.saveQuotes(quotes)

        // When
        let savedQuotes = try await sut.getQuotes()

        // Then
        XCTAssertEqual(savedQuotes, quotes)        
    }

    func test_getQuotes_whenNoQuotesSaved_returnEmptyArray() async throws {
        // When
        let quotes = try await sut.getQuotes()

        // Then
        XCTAssertTrue(quotes.isEmpty)
    }
}

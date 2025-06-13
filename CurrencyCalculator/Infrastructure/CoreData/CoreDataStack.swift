//
//  CoreDataStack.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/18.
//

import CoreData

///
/// A wrapper to encapsulate initialization for Core Data stack
///
final class CoreDataStack {
    enum Store {
        case currencyCalculator, testCurrencyCalculator

        var storeName: String {
            switch self {
            case .currencyCalculator, .testCurrencyCalculator:
                "CurrencyCalculatorDataModel"
            }
        }

        var storeDescription: NSPersistentStoreDescription {
            switch self {
            case .currencyCalculator:
                return NSPersistentStoreDescription()
            case .testCurrencyCalculator:
                // For unit testing, using an SQLite store that writes to /dev/null
                // is close to real usage than NSInMemoryStoreType based store.
                let description = NSPersistentStoreDescription()
                description.url = URL(fileURLWithPath: "/dev/null")
                return description
            }
        }
    }

    // Reuse the loaded object model for NSPersistentContainer loading
    private static var _model: NSManagedObjectModel?
    private static func model(name: String) -> NSManagedObjectModel {
        if _model == nil {
            _model = loadModel(name: name, bundle: Bundle.main)
        }
        return _model!
    }

    private static func loadModel(name: String, bundle: Bundle) -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            fatalError("CoreData model URL not found")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("CoreData model failed to load")
        }
        return model
    }

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let name = "CurrencyCalculatorDataModel"
        let container = NSPersistentContainer(
            name: self.store.storeName,
            managedObjectModel: CoreDataStack.model(name: name)
        )
        container.persistentStoreDescriptions = [self.store.storeDescription]

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData store failed to load; error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()

    private let store: Store

    init(store: Store) {
        self.store = store
    }
}

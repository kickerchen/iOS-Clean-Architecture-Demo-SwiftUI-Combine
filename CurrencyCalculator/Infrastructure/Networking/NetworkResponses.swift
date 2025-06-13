//
//  NetworkResponses.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/20.
//

import Foundation

//
// Structs to represent the responses from Open Exchange Rates API
//

//
//    Response data from endpoint /currencies.json
//
//    Example:
//    {
//        "AED": "United Arab Emirates Dirham",
//        "AFN": "Afghan Afghani",
//        "ALL": "Albanian Lek",
//        "AMD": "Armenian Dram",
//        "ANG": "Netherlands Antillean Guilder",
//    }
//
typealias CurrenciesResponse = [String: String]

//
//    Response data from endpoint /latest.json
//
//    Example:
//    {
//        "disclaimer": "Usage subject to terms: https://openexchangerates.org/terms",
//        "license": "https://openexchangerates.org/license",
//        "timestamp": 1744822816,
//        "base": "USD",
//        "rates": {
//            "AED": 3.673005,
//            "AFN": 72.495777,
//            "ALL": 87.46497,
//            "AMD": 391.27,
//        }
//    }
//
struct LatestResponse: Decodable {
    let disclaimer: String
    let license: String
    let timestamp: Date
    let base: String
    let rates: [String: Decimal]
}

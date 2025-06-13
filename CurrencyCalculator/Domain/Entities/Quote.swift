//
//  Quote.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

///
/// Represent a object of a quote curreny
/// id: The country code
/// rate: The exchange rate
///
struct Quote: Identifiable, Hashable {
    let id: String
    let rate: Decimal
}

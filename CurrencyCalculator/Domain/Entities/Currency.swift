//
//  Currency.swift
//  CurrencyCalculator
//
//  Created by Kicker Chen on 2025/4/17.
//

import Foundation

///
/// Represent a object of a curreny
/// id: The country code
/// fullName: The full name of the currency
///
struct Currency: Identifiable, Hashable {
    let id: String
    let fullName: String
}

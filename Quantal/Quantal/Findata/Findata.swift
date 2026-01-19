//
//  Findata.swift
//  Quantal
//
//  Created by Petr Homola on 19/01/2026.
//

import SwiftUI

enum RuntimeError: Error {
    case badUrl
    case badDateTime
    case errorResponse(statusCode: Int)
}

enum Interval: Identifiable {
    case hour1
    case day1
    
    var id: Self { self }
    
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .hour1: return LocalizedStringKey("1hour")
        case .day1: return LocalizedStringKey("1day")
        }
    }
}

protocol DataMeta {
    var currency: String { get }
    var fullExchangeName: String { get }
    var timezone: String { get }
}

struct Candle: Identifiable {
    let index: Int
    let timestamp: Date
    let volume: Float64
    let open: Float64
    let close: Float64
    let low: Float64
    let high: Float64
    
    var id: Int { index }
}

protocol DataProvider {
    func fetchData(symbol: String, from: Date, to: Date, interval: Interval) async throws -> ([Candle], DataMeta)
}

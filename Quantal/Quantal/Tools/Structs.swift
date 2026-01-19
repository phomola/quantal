//
//  Structs.swift
//  Quantal
//
//  Created by Petr Homola on 19/01/2026.
//

import Foundation
import FoundationModels

@Generable(description: "date components")
struct DateComponents {
    let day: Int
    let month: Int
    let year: Int
    
    var date: Foundation.DateComponents {
        Foundation.DateComponents(year: year, month: month, day: day)
    }
}

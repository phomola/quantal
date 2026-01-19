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
    
    init?(components: Foundation.DateComponents) {
        guard let day = components.day else { return nil }
        guard let month = components.month else { return nil }
        guard let year = components.year else { return nil }
        self.day = day
        self.month = month
        self.year = year
    }
    
    var date: Foundation.DateComponents {
        Foundation.DateComponents(year: year, month: month, day: day)
    }
}

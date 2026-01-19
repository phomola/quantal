//
//  Tools.swift
//  Quantal
//
//  Created by Petr Homola on 19/01/2026.
//

import Foundation

struct DynamicTool {
    let name: String
    let description: String
    let arguments: [Argument]
    
    struct Argument {
        let name: String
        let guide: String
    }
}

protocol ToolManager {
    func pickTool(for query: String) -> DynamicTool
}

//
//  Tools.swift
//  Quantal
//
//  Created by Petr Homola on 19/01/2026.
//

import Foundation
import FoundationModels

struct DynamicTool {
    let info: String
    let tool: any Tool
}

protocol ToolManaging {
    func pickTool(for query: String) -> DynamicTool?
}

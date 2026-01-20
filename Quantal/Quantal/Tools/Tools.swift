//
//  Tools.swift
//  Quantal
//
//  Created by Petr Homola on 19/01/2026.
//

import Foundation
import FoundationModels

@available(macOS 26.0, *)
struct DynamicTool {
    let info: String
    let tool: any Tool
}

@available(macOS 26.0, *)
protocol ToolManagement {
    func add(tool: any Tool) throws
    func pickTool(for query: String) -> DynamicTool?
}

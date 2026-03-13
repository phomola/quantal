//
//  JSTool.swift
//  Quantal
//
//  Created by Petr Homola on 13/03/2026.
//

import Foundation
import FoundationModels
@preconcurrency import JavaScriptCore

@available(macOS 26.0, *)
struct JSTool: Tool {
    let name: String
    let description: String
    let parameters: GenerationSchema
    let function: JSValue
    
    init(name: String, description: String, schema: GenerationSchema, function: JSValue) throws {
        self.name = name
        self.description = description
        self.parameters = schema
        self.function = function
    }
    
    typealias Arguments = GeneratedContent
    
    func call(arguments: Arguments) async throws -> GeneratedContent {
        print("tool invoked: \(name) / \(arguments.jsonString)")
        guard let input = arguments.jsonString.data(using: .utf8) else { throw ServiceError.badData }
        let inputDict = try JSONSerialization.jsonObject(with: input)
        let result = try await callAsync(function: self.function, arguments: [inputDict])
        let json = try JSONSerialization.data(withJSONObject: result)
        return try GeneratedContent(json: String(data: json, encoding: .utf8) ?? "{}")
    }
}

func callAsync(function: JSValue, arguments: [Any] = []) async throws -> JSValue {
    try await withCheckedThrowingContinuation { continuation in
        let onFulfilled: @convention(block) (JSValue) -> Void = {
            continuation.resume(returning: $0)
        }
        let onRejected: @convention(block) (JSValue) -> Void = {
            let error = NSError(domain: "async JS call", code: 0, userInfo: [NSLocalizedDescriptionKey : "\($0)"])
            continuation.resume(throwing: error)
        }
        let promise = function.call(withArguments: arguments)
        promise?.invokeMethod("then", withArguments: [onFulfilled, onRejected])
    }
}

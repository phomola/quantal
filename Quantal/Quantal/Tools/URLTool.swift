//
//  URLTool.swift
//  Quantal
//
//  Created by Petr Homola on 12/03/2026.
//

import Foundation
import FoundationModels

enum ServiceError: Error {
    case badRequest, badUrl, badResponse, badData
}

func fetch(from url: URL, input: Data) async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = input
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else if let response = response as? HTTPURLResponse, let data = data {
                if response.statusCode == 200 {
                    continuation.resume(returning: data)
                } else {
                    print("unexpected status code: \(response.statusCode)")
                    continuation.resume(throwing: ServiceError.badResponse)
                }
            } else {
                print("no HTTP response or data")
                continuation.resume(throwing: ServiceError.badResponse)
            }
        })
        task.resume()
    }
}

@available(macOS 26.0, *)
struct URLTool: Tool {
    let name: String
    let description: String
    let parameters: GenerationSchema
    let url: URL
    
    init(name: String, description: String, urlString: String, schema: GenerationSchema) throws {
        self.name = name
        self.description = description
        guard let url = URL(string: urlString) else { throw ServiceError.badUrl }
        self.url = url
        self.parameters = schema
    }
    
    typealias Arguments = GeneratedContent
    
    func call(arguments: Arguments) async throws -> String {
        print("tool invoked: \(url) / \(arguments.jsonString)")
        guard let input = arguments.jsonString.data(using: .utf8) else { throw ServiceError.badData }
        guard let output = String(data: try await fetch(from: url, input: input), encoding: .utf8) else { throw ServiceError.badData }
        return output
    }
}

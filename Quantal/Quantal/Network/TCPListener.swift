//
//  TCPListener.swift
//  Quantal
//
//  Created by Petr Homola on 09/03/2026.
//

import Foundation
import Network

extension NWConnection {
    func receive(maximumLength: Int) async throws -> (Data?, Bool) {
        try await withCheckedThrowingContinuation { continuation in
            self.receive(minimumIncompleteLength: 1, maximumLength: maximumLength) { data, _, isComplete, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data, isComplete))
                }
            }
        }
    }
    
    func receiveAll() async throws -> Data {
        var allData = Data()
        while true {
            let (data, isComplete) = try await self.receive(maximumLength: 64 * 1024)
            if let data { allData.append(data) }
            if isComplete { break }
        }
        return allData
    }

    func send(data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.send(content: data, contentContext: .finalMessage, isComplete: true, completion: .contentProcessed { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
}

class TCPListener {
    let listener: NWListener
    
    init(port: UInt16, localOnly: Bool) throws {
        let params = NWParameters.tcp
        params.acceptLocalOnly = localOnly
        self.listener = try NWListener(using: params, on: .init(integerLiteral: port))
    }
    
    func listenAndServe(queue: DispatchQueue, handler: @escaping (Data) async throws -> Data) {
        self.listener.newConnectionHandler = { connection in
            connection.start(queue: queue)
            Task {
                defer { connection.cancel() }
                do {
                    let input = try await connection.receiveAll()
                    let output = try await handler(input)
                    try await connection.send(data: output)
                } catch {
                    print("connection error: \(error)")
                }
            }
        }
        self.listener.start(queue: queue)
    }
}

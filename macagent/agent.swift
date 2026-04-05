import Foundation
import FoundationModels
import NaturalLanguage

enum AgentError: Error {
    case noModel
    case noEmbedding
    case noSuitableSkill
    case appleScriptError
    case unrecognizedLanguage
    case missingUserInput
    case notImplemented
}

actor Context {
    var input: String? = nil

    func set(input: String) {
        self.input = input
    }
}

final class Agent {
    let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
    let embedding: NLEmbedding
    var session: LanguageModelSession?
    let context = Context()

    init() throws {
        if !model.isAvailable { throw AgentError.noModel }
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else { throw AgentError.noEmbedding }
        self.embedding = embedding
    }

    func startSession() {
        let proxyTool = ProxyTool(embedding: embedding, model: model, context: context)
        let session = LanguageModelSession(model: model, tools: [proxyTool], instructions: """
            To perform external actions use the provided proxy tool. Pass all parts of the user input to the proxy tool.
            """)
        session.prewarm()
        self.session = session
    }

    func respond(to prompt: String) async throws -> String {
        if let session {
            await context.set(input: prompt)
            let response = try await session.respond(to: prompt)
            return response.content
        } else {
            return "No session in place."
        }
    }
}

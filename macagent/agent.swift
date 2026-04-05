import Foundation
import FoundationModels
import NaturalLanguage

enum AgentError: Error {
    case noModel
    case noEmbedding
    case noSuitableSkill
    case appleScriptError
    case notImplemented
}

class Agent {
    let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
    let session: LanguageModelSession

    init() throws {
        if !model.isAvailable { throw AgentError.noModel }
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else { throw AgentError.noEmbedding }
        let tool = ProxyTool(embedding: embedding, model: model)
        session = LanguageModelSession(model: model, tools: [tool])
        session.prewarm()
    }
}

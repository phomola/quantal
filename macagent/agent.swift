import Foundation
import FoundationModels

enum AgentError: Error {
    case noModel
}

class Agent {
    let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
    let session: LanguageModelSession

    init() throws {
        if !model.isAvailable { throw AgentError.noModel }
        self.session = LanguageModelSession(model: model)
    }
}

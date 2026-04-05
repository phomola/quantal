import Foundation
import FoundationModels
@preconcurrency import NaturalLanguage

struct ProxyTool: Tool {
    let description = "Invoke this tool to perform external actions. Provide the whole user prompt, don't extract pieces from it."
    let embedding: NLEmbedding
    let model: SystemLanguageModel
    let skills: [Skill] = [
        OpenAppSkill(),
        WebSearchSkill(),
    ]

    @Generable
    struct Arguments {
        @Guide(description: "The whole original user prompt. Provide the whole user prompt, don't extract pieces from it.")
        let originalPrompt: String
    }

    struct RatedSkill {
        let skill: Skill
        let distance: NLDistance
    }

    func call(arguments: Arguments) async throws -> String {
        let query = arguments.originalPrompt
        print("proxy tool query: '\(query)'")
        var ratedSkills: [RatedSkill] = []
        ratedSkills.reserveCapacity(skills.count)
        for skill in skills {
            let distance = embedding.distance(between: query, and: skill.description, distanceType: .cosine)
            ratedSkills.append(RatedSkill(skill: skill, distance: distance))
        }
        ratedSkills.sort { $0.distance < $1.distance }
        for ratedSkill in ratedSkills {
            let skill = ratedSkill.skill
            let session = LanguageModelSession(model: model, tools: [skill.tool])
            do {
                let response = try await session.respond(to: query, generating: SkillResult.self)
                if !response.content.success { print("skill failed") }
                return response.content.message
            } catch {
                print("skill error: \(error)")
            }
        }
        throw AgentError.noSuitableSkill
    }
}

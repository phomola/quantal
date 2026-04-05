import Foundation
import FoundationModels

protocol Skill: Sendable {
    var description: String { get }
    var tool: any Tool { get }
}

@Generable
struct SkillResult {
    let message: String
    let success: Bool
}

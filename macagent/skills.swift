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

func run(appleScript script: String, successMessage: String) -> SkillResult {
    guard let script = NSAppleScript(source: script) else { return SkillResult(message: "AppleScript couldn't be created.", success: false) }
    var errorInfo: NSDictionary? = nil
    script.executeAndReturnError(&errorInfo)
    if errorInfo == nil {
        return SkillResult(message: successMessage, success: true)
    } else {
        return SkillResult(message: errorInfo?[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error.", success: false)
    }
}

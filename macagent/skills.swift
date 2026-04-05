import Foundation
import FoundationModels

protocol Skill: Sendable {
    var description: String { get }
    var tool: any Tool { get }
}

struct OpenAppSkill: Skill {
    let description = """
        Opens an application.
        Arguments:
        appName (string): The name of the application.
        """
    let tool: any Tool = SkillTool()

    struct SkillTool: Tool {
        let description = "Opens an application."

        @Generable
        struct Arguments {
            @Guide(description: "The name of the application to be open.")
            let appName: String
        }

        func call(arguments: Arguments) async throws -> String {
            let appName = arguments.appName
            print("open app skill: \(appName)")
            guard let script = NSAppleScript(source: """
                tell application "\(appName)"
                    activate
                end tell
                """) else { throw AgentError.appleScriptError }
            var errorInfo: NSDictionary? = nil
            script.executeAndReturnError(&errorInfo)
            if errorInfo == nil {
                return "App opened."
            } else {
                return errorInfo?[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error."
            }
        }
    }
}

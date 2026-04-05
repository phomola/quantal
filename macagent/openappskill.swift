import Foundation
import FoundationModels

struct OpenAppSkill: Skill {
    let description = """
        Opens an application on the running system.
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

        func call(arguments: Arguments) async throws -> SkillResult {
            let appName = arguments.appName
            print("open app skill: '\(appName)'")
            return await MainActor.run {
                guard let script = NSAppleScript(source: """
                    tell application "\(appName)"
                        activate
                    end tell
                    """) else { return SkillResult(message: "AppleScript couldn't be created.", success: false) }
                var errorInfo: NSDictionary? = nil
                script.executeAndReturnError(&errorInfo)
                if errorInfo == nil {
                    return SkillResult(message: "App opened.", success: true)
                } else {
                    return SkillResult(message: errorInfo?[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error.", success: false)
                }
            }
        }
    }
}

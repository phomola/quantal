import Foundation
import FoundationModels

struct OpenAppSkill: Skill {
    let description = """
        Opens an application on the running system. The app is open using AppleScript.

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
                return run(appleScript: """
                    tell application "\(appName)"
                        activate
                    end tell
                    """, successMessage: "App opened.")
            }
        }
    }
}

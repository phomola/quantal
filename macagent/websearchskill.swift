import Foundation
import FoundationModels

struct WebSearchSkill: Skill {
    let description = """
        Searches information on the internet using a web browser.

        Arguments:

        phrase (string): The phrase to search for.
        """
    let tool: any Tool = SkillTool()

    struct SkillTool: Tool {
        let description = "Opens an application."

        @Generable
        struct Arguments {
            @Guide(description: "The phrase to search for.")
            let phrase: String
        }

        func call(arguments: Arguments) async throws -> SkillResult {
            let phrase = arguments.phrase
            print("web search skill: '\(phrase)'")
            return await MainActor.run {
                return run(appleScript: """
                    tell application "Safari"
                        search the web for "\(phrase)"
                    end tell
                    """, successMessage: "Search performed in Safari.")
            }
        }
    }
}

// Example: Search for "Argentinian Andes" on the web.

import Foundation
import FoundationModels
import NaturalLanguage
import Translation

struct MTSkill: Skill {
    let description = """
        Translates a text to another natural language.

        Arguments:
        
        targetLanguage (string): The language to translate to.
        text (string): The text to translate.
        """
    let tool: any Tool = SkillTool()

    struct SkillTool: Tool {
        let description = "Translates a text to another natural language."

        @Generable
        struct Arguments {
            @Guide(description: "The two-letter ISO code of the language to translate to.")
            let targetLanguage: String
            @Guide(description: "The text to translate.")
            let text: String
        }

        func call(arguments: Arguments) async throws -> SkillResult {
            let text = arguments.text
            guard let language = NLLanguageRecognizer.dominantLanguage(for: text) else { throw AgentError.unrecognizedLanguage }
            let sourceLanguage = Locale.Language(identifier: language.rawValue)
            let targetLanguage = Locale.Language(identifier: arguments.targetLanguage)
            print("MT skill: '\(text)' (\(sourceLanguage.languageCode ?? "???") -> \(targetLanguage.languageCode ?? "???"))")
            let session = TranslationSession(installedSource: sourceLanguage, target: targetLanguage)
            let response = try await session.translate(text)
            // print("# \(response.targetText)")
            return SkillResult(message: response.targetText, success: true)
        }
    }
}

// Example: Translate to Spanish: I'll go home soon because I'm tired.

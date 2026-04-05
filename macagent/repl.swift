import Foundation

func runREPL() async throws {
    let agent = try Agent()
    print("waiting for your input")
    print(">", terminator: " ")
    while let input = readLine() {
        let input = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if input == "" { continue }
        let response = try await agent.session.respond(to: input)
        print("\n\(response.content)")
        print("\n>", terminator: " ")
    }
}

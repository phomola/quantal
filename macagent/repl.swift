import Foundation

func runREPL() async throws {
    let agent = try Agent()
    agent.startSession()
    print("waiting for your input")
    print(">", terminator: " ")
    while let input = readLine() {
        let input = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if input == "" { continue }
        do {
            let response = try await agent.respond(to: input)
            print("\n\(response)")
        } catch {
            print("\nerror: \(error)")
        }
        print("\n>", terminator: " ")
    }
}

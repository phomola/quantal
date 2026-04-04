import Foundation

func runREPL() throws {
    let agent = try Agent()
    while let input = readLine() {
        let input = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if input == "" { continue }
        print("> '\(input)'")
    }
}

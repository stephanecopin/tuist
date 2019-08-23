import Foundation

public struct LintingError: FatalError, Equatable {
    public var description: String = "Fatal linting issues found"
    public var type: ErrorType = .abort
}

/// Linting issue.
public struct LintingIssue: CustomStringConvertible, Equatable {
    public enum Severity: String {
        case warning
        case error
    }

    // MARK: - Attributes

    public let reason: String
    public let severity: Severity

    // MARK: - Init

    public init(reason: String, severity: Severity) {
        self.reason = reason
        self.severity = severity
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return reason
    }

    // MARK: - Equatable

    public static func == (lhs: LintingIssue, rhs: LintingIssue) -> Bool {
        return lhs.severity == rhs.severity &&
            lhs.reason == rhs.reason
    }
}

// MARK: - Array Extension (Linting issues)

public extension Array where Element == LintingIssue {
    func printAndThrowIfNeeded() throws {
        if count == 0 { return }

        let errorIssues = filter { $0.severity == .error }
        let warningIssues = filter { $0.severity == .warning }

        if !warningIssues.isEmpty {
            Printer.shared.print("The following issues have been found:", color: .yellow)
            let message = warningIssues.map { "  - \($0.description)" }.joined(separator: "\n")
            Printer.shared.print(message)
        }

        if !errorIssues.isEmpty {
            let prefix = !warningIssues.isEmpty ? "\n" : ""
            Printer.shared.print("\(prefix)The following critical issues have been found:", output: .standardError)
            let message = errorIssues.map { "  - \($0.description)" }.joined(separator: "\n")
            Printer.shared.print(message, output: .standardError)

            throw LintingError()
        }
    }
}

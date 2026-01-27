public protocol Condition: Equatable, Sendable {
    /// Given an entire OpenAPI Document, determine the applicability of the
    /// condition.
    func applies(to: OpenAPI.Document) -> Bool
}

public protocol HasConditionalWarnings {
    /// Warnings that only apply if the paired condition is met.
    ///
    /// Among other things, this allows OpenAPIKit to generate a warning in
    /// some nested type that only applies if the OpenAPI Standards version of
    /// the document is less than a certain version.
    var conditionalWarnings: [(any Condition, OpenAPI.Warning)] { get }
}

extension HasConditionalWarnings {
    public func applicableConditionalWarnings(for subject: OpenAPI.Document) -> [OpenAPI.Warning] {
        conditionalWarnings.compactMap { (condition, warning) in
            guard condition.applies(to: subject) else { return nil }

            return warning
        }
    }
}

internal struct DocumentVersionCondition: Sendable, Condition {
    enum Comparator: Sendable {
        case lessThan
        case equal
        case greaterThan
    }

    let version: OpenAPI.Document.Version
    let comparator: Comparator

    func applies(to document: OpenAPI.Document) -> Bool {
        switch comparator {
        case .lessThan: document.openAPIVersion < version

        case .equal: document.openAPIVersion == version

        case .greaterThan: document.openAPIVersion > version
        }
    }
}

internal extension OpenAPI.Document {
    struct ConditionalWarnings {
        static func version(lessThan version: OpenAPI.Document.Version, doesNotSupport subject: String) -> (any Condition, OpenAPI.Warning) {
            let warning = OpenAPI.Warning.message("\(subject) is only supported for OpenAPI document versions \(version.rawValue) and later")

            return (DocumentVersionCondition(version: version, comparator: .lessThan), warning)
        }

        static func version(lessThan version: OpenAPI.Document.Version, doesNotAllowOptional subject: String) -> (any Condition, OpenAPI.Warning) {
            let warning = OpenAPI.Warning.message("\(subject) cannot be nil for OpenAPI document versions lower than \(version.rawValue)")

            return (DocumentVersionCondition(version: version, comparator: .lessThan), warning)
        }

        static func nonNilVersionWarning<Subject>(objectName: String, fieldName: String, value: Subject?, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
            value.map { _ in
                OpenAPI.Document.ConditionalWarnings.version(
                    lessThan: minimumVersion,
                    doesNotSupport: "The \(objectName) \(fieldName) field"
                )
            }
        }

        static func nonEmptyVersionWarning<Key,  Value>(objectName: String, fieldName: String, value: OrderedDictionary<Key, Value>, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
            if value.isEmpty { return nil }

            return OpenAPI.Document.ConditionalWarnings.version(
                lessThan: minimumVersion,
                doesNotSupport: "The \(objectName) \(fieldName) map"
            )
        }
    }
}

internal enum OASWarnings {
    typealias Doc = OpenAPI.Document.ConditionalWarnings
}

//
//  GenericError.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

/// This error type is thrown when a problem _during_ encoding or decoding but the
/// problem is not inherent to the types or structures but rather specific
/// to the OpenAPI specification rules.
public struct GenericError: Swift.Error, CustomStringConvertible, OpenAPIError {
    public let subjectName: String
    public let details: String
    public let codingPath: [CodingKey]
    public let pathIncludesSubject: Bool

    public var contextString: String { "" }
    public var errorCategory: ErrorCategory { .inconsistency(details: details) }

    public var localizedDescription: String { details }

    public var description: String { localizedDescription }

    public init(subjectName: String, details: String, codingPath: [CodingKey], pathIncludesSubject: Bool = true) {
        self.subjectName = subjectName
        self.details = details
        self.codingPath = codingPath
        self.pathIncludesSubject = pathIncludesSubject
    }
}

//
//  ContextualizedError.swift
//  
//
//  Created by Mathew Polzin on 12/19/21.
//

public struct CodingPathError: Swift.Error, CustomStringConvertible, OpenAPIError {
    public let details: String
    public let codingPath: [CodingKey]

    public var subjectName: String { "" }
    public var contextString: String { "" }
    public var errorCategory: ErrorCategory { .inconsistency(details: details) }

    public var localizedDescription: String { details }

    public var description: String { localizedDescription }

    public init(details: String, codingPath: [CodingKey]) {
        self.details = details
        self.codingPath = codingPath
    }
}

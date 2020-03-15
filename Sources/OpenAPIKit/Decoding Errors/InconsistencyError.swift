//
//  InconsistencyError.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

import Foundation

/// This error type is thrown when a problem _during_ decoding but the
/// problem is not inherent to the types or structures but rather specific
/// to the OpenAPI specification rules.
public struct InconsistencyError: Swift.Error, OpenAPIError {
    public let subjectName: String
    public let details: String
    public let codingPath: [CodingKey]

    public var contextString: String { "" }
    public var errorCategory: ErrorCategory { .inconsistency(details: details) }

    public var localizedDescription: String { details }
}

//
//  InconsistencyError.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

import Foundation

public struct InconsistencyError: Swift.Error, OpenAPIError {
    public let subjectName: String
    public let details: String
    public let codingPath: [CodingKey]

    public var contextString: String { "" }
    public var errorCategory: ErrorCategory { .inconsistency(details: details) }

    public var localizedDescription: String { details }
}

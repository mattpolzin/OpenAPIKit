//
//  OpenAPIError.swift
//  
//
//  Created by Mathew Polzin on 3/30/20.
//

/// An `OpenAPI.Error` can be constructed from any error thrown while decoding
/// an OpenAPI document.  This wrapper provides a superior human-readable error
/// and a human readable coding path.
///
/// Example:
///
///     do {
///         document = try JSONDecoder().decode(OpenAPI.Document.self, from: ...)
///     } catch let error {
///         let prettyError = OpenAPI.Error(from: error)
///         print(prettyError.localizedDescription)
///         print(prettyError.codingPathString)
///     }
///
public struct Error: Swift.Error, CustomStringConvertible {

    public let localizedDescription: String
    public let codingPath: [CodingKey]
    public let underlyingError: Swift.Error

    public var codingPathString: String { codingPath.stringValue }

    public init(from underlyingError: Swift.Error) {
        self.underlyingError = underlyingError
        if let openAPIError = underlyingError as? OpenAPIError {
            localizedDescription = openAPIError.localizedDescription
            codingPath = openAPIError.codingPath

        } else if let decodingError = underlyingError as? Swift.DecodingError {

            if let openAPIError = decodingError.underlyingError as? OpenAPIError {
                localizedDescription = openAPIError.localizedDescription
                codingPath = openAPIError.codingPath
            } else {
                let wrappedError = DecodingErrorWrapper(decodingError: decodingError)
                localizedDescription = wrappedError.localizedDescription
                codingPath = wrappedError.codingPath
            }

        } else if let errorCollection = underlyingError as? ErrorCollection {
            localizedDescription = errorCollection.localizedDescription
            codingPath = []

        } else {
            localizedDescription = underlyingError.localizedDescription
            codingPath = []
        }
    }

    public var description: String { localizedDescription }
}

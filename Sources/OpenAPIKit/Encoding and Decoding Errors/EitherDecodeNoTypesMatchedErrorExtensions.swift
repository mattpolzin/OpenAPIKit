//
//  EitherDecodeNoTypesMatchedErrorExtensions.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

import Foundation

internal extension EitherDecodeNoTypesMatchedError {
    var subjectName: String {
        return codingPath.last?.stringValue ?? "[unknown object]"
    }

    var codingPathWithoutSubject: [CodingKey] {
        return codingPath.count > 0 ? codingPath.dropLast() : []
    }

    var relativeCodingPathString: String {
        return codingPathWithoutSubject.stringValue
    }

    var errorCategory: ErrorCategory {
        guard
            individualTypeFailures.count == 2,
            let failure1 = individualTypeFailures.first,
            let failure2 = individualTypeFailures.dropFirst().first
            else {
                return .dataCorrupted(underlying: self)
        }

        func isRefKeyNotFoundError(_ failure: IndividualFailure) -> Bool {
            guard case .keyNotFound(let key, _) = failure.error else {
                return false
            }
            return key.stringValue == "$ref"
        }

        // We want to omit details if the problem is a missing '$ref' key.
        // If the intention was to write a reference, this error will be obvious.
        // If the intention was not to use a reference, this error will be superfluous.
        let error1 = isRefKeyNotFoundError(failure1)
            ? nil
            : OpenAPI.Error(from: failure1.error.replacingPath(with: failure1.codingPath(relativeTo: codingPath))).localizedDescription
        let error2 = isRefKeyNotFoundError(failure2)
            ? nil
            : OpenAPI.Error(from: failure2.error.replacingPath(with: failure2.codingPath(relativeTo: codingPath))).localizedDescription

        let details1 = error1
            .map { "\(String(describing: failure1.type)) could not be decoded because:\n\($0)" }
            .map { "\n\n" + $0 }
            ?? ""
        let details2 = error2
            .map { "\(String(describing: failure2.type)) could not be decoded because:\n\($0)" }
            .map { "\n\n" + $0 }
            ?? ""

        let details = details1 + details2

        return .typeMismatch2(
            possibleTypeName1: failure1.typeString,
            possibleTypeName2: failure2.typeString,
            details: details
        )
    }
}

internal extension EitherDecodeNoTypesMatchedError.IndividualFailure {
    func codingPath(relativeTo other: [CodingKey]) -> [CodingKey] {
        fullCodingPath.relative(to: other)
    }

    var typeString: String {
        if (type as? OpenAPIKit._OpenAPIReference.Type) != nil {
            return "$ref"
        }
        return String(describing: type)
    }

    /// This retrieves the coding path of any underlying error
    /// which will be at least as long if not longer than that of
    /// the `IndividualFailure`
    var fullCodingPath: [CodingKey] {
        if let decodingError = error.underlyingError as? DecodingError {
            return decodingError.codingPath
        }
        if let inconsistencyError = error.underlyingError as? InconsistencyError {
            return inconsistencyError.codingPath
        }
        if let eitherError = error.underlyingError as? EitherDecodeNoTypesMatchedError {
            return eitherError.codingPath
        }
        if let openApiError = error.underlyingError as? OpenAPIError {
            return openApiError.codingPath
        }
        return error.codingPath
    }
}

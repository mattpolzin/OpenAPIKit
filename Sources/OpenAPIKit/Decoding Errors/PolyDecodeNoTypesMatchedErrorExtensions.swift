//
//  PolyDecodeNoTypesMatchedErrorExtensions.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

import Foundation
import Poly

internal extension PolyDecodeNoTypesMatchedError {
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
        //
        // We get away with assuming the choice is between either of 2
        // types currently. Likely we will not need to ever worry about
        // a Poly3 or beyond when parsing OpenAPI documents (with the notable
        // exception of parsing OpenAPI schemas)
        //
        guard
            individualTypeFailures.count == 2,
            let f1 = individualTypeFailures.first,
            let f2 = individualTypeFailures.dropFirst().first
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
        let error1 = isRefKeyNotFoundError(f1)
            ? nil
            : OpenAPI.Error(from: f1.error.replacingPath(with: f1.codingPath(relativeTo: codingPath))).localizedDescription
        let error2 = isRefKeyNotFoundError(f2)
            ? nil
            : OpenAPI.Error(from: f2.error.replacingPath(with: f2.codingPath(relativeTo: codingPath))).localizedDescription

        let details1 = error1
            .map { "\(String(describing: f1.type)) could not be decoded because:\n\($0)" }
            .map { "\n\n" + $0 }
            ?? ""
        let details2 = error2
            .map { "\(String(describing: f2.type)) could not be decoded because:\n\($0)" }
            .map { "\n\n" + $0 }
            ?? ""

        let details = details1 + details2

        return .typeMismatch2(
            possibleTypeName1: f1.typeString,
            possibleTypeName2: f2.typeString,
            details: details
        )
    }
}

internal extension PolyDecodeNoTypesMatchedError.IndividualFailure {
    func codingPath(relativeTo other: [CodingKey]) -> [CodingKey] {
        fullCodingPath.relative(to: other)
    }

    var typeString: String {
        if (type as? Reference.Type) != nil {
            return "$ref"
        }
        return String(describing: type)
    }

    /// This retrieves the coding path of any underlying error
    /// which will be at least as long if not longer than that of
    /// the `IndividualFailure`
    var fullCodingPath: [CodingKey] {
        if let err = error.underlyingError as? DecodingError {
            return err.codingPath
        }
        if let err = error.underlyingError as? InconsistencyError {
            return err.codingPath
        }
        if let err = error.underlyingError as? PolyDecodeNoTypesMatchedError {
            return err.codingPath
        }
        return error.codingPath
    }
}

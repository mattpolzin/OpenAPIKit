//
//  EitherDecodeNoTypesMatchedErrorExtensions.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

public extension EitherDecodeNoTypesMatchedError {
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

        func looksLikeReferenceKey(_ failure: IndividualFailure) -> Bool {
            guard case .dataCorrupted(let e) = failure.error else {
                return false
            }
            return e.codingPath[e.codingPath.count-1].stringValue == "$ref"
        }

        // - We want to omit details if the problem is a missing '$ref' key.
        // - If the intention was not to use a reference, a reference error will be superfluous.
        // - If the intention was to write a reference and `$ref` was not used, this error will be obvious.
        // - If the intention was to write a reference and `$ref` _was_ used, we definitely want to zero in
        //   on the reference error (which means omitting the _other_ error).
        let error1 = isRefKeyNotFoundError(failure1)
            ? nil
            : looksLikeReferenceKey(failure2)
                ? nil
                : Error(from: failure1.error.replacingPath(with: failure1.codingPath(relativeTo: codingPath))).localizedDescription
        let error2 = isRefKeyNotFoundError(failure2)
            ? nil
            : looksLikeReferenceKey(failure1)
                ? nil
                : Error(from: failure2.error.replacingPath(with: failure2.codingPath(relativeTo: codingPath))).localizedDescription

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
        if (type as? OpenAPIKitCore._OpenAPIReference.Type) != nil {
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
        if let inconsistencyError = error.underlyingError as? GenericError {
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

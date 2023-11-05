//
//  Either+Codable.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/12/19.
//

// MARK: - Generic Decoding

public struct EitherDecodeNoTypesMatchedError: Swift.Error, CustomStringConvertible {

    public struct IndividualFailure: Swift.Error {
        public let type: Any.Type
        public let error: DecodingError
    }

    public let codingPath: [CodingKey]
    public let individualTypeFailures: [IndividualFailure]

    public var description: String {
        let codingPathString = codingPath
            .map { $0.intValue.map(String.init) ?? $0.stringValue }
            .joined(separator: "/")

        let failureStrings = individualTypeFailures.map {
            let type = $0.type
            let error = ($0.error as CustomDebugStringConvertible).debugDescription
            return "\(String(describing: type)) could not be decoded because:\n\(error)"
        }.joined(separator: "\n\n")

        return """
        Either failed to decode any of its types at: "\(codingPathString)"

        \(failureStrings)
        """
    }
}

private typealias EitherTypeNotFound = EitherDecodeNoTypesMatchedError.IndividualFailure

private func decode<Thing: Decodable>(_ type: Thing.Type, from container: SingleValueDecodingContainer) throws -> Result<Thing, EitherTypeNotFound> {
	let result: Result<Thing, EitherTypeNotFound>
	do {
		result = try .success(container.decode(Thing.self))
	} catch (let error as DecodingError) {
		result = .failure(EitherTypeNotFound(type: type, error: error))
	} catch (let error) {
        result = .failure(EitherTypeNotFound(
            type: type,
            error: DecodingError.typeMismatch(
                Thing.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: String(describing: error),
                    underlyingError: error
                )
            )
        ))
	}
	return result
}

extension Either: Encodable where A: Encodable, B: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
		case .a(let a):
			try container.encode(a)
		case .b(let b):
			try container.encode(b)
		}
	}
}

extension Either: Decodable where A: Decodable, B: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

        // try for an `A`
        let attemptA = try decode(A.self, from: container).map { Either.a($0) }
        if case let .success(a) = attemptA {
            self = a
            return
        }

        // try for a `B`
        let attemptB = try decode(B.self, from: container).map { Either.b($0) }
        if case let .success(b) = attemptB {
            self = b
            return
        }

        let individualFailures = [attemptA, attemptB].map { $0.error }.compactMap { $0 }

        throw EitherDecodeNoTypesMatchedError(
            codingPath: decoder.codingPath,
            individualTypeFailures: individualFailures
        )
	}
}

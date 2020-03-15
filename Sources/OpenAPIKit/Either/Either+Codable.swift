//
//  Either+Codable.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/12/19.
//

// MARK: - Generic Decoding

public struct EitherDecodeNoTypesMatchedError: Swift.Error, CustomDebugStringConvertible {

    public struct IndividualFailure: Swift.Error {
        public let type: Any.Type
        public let error: DecodingError
    }

    public let codingPath: [CodingKey]
    public let individualTypeFailures: [IndividualFailure]

    public var debugDescription: String {
        let codingPathString = codingPath
            .map { $0.intValue.map(String.init) ?? $0.stringValue }
            .joined(separator: "/")

        let failureStrings = individualTypeFailures.map {
            let type = $0.type
            let descriptiveError = $0.error as? CustomDebugStringConvertible
            let error = descriptiveError?.debugDescription ?? String(describing: $0.error)
            return "\(String(describing: type)) could not be decoded because:\n\(error)"
        }.joined(separator: "\n\n")

        return
"""
Either failed to decode any of its types at: "\(codingPathString)"

\(failureStrings)
"""
    }
}

private typealias EitherTypeNotFound = EitherDecodeNoTypesMatchedError.IndividualFailure

private func decode<Thing: Decodable>(_ type: Thing.Type, from container: SingleValueDecodingContainer) throws -> Result<Thing, EitherTypeNotFound> {
	let ret: Result<Thing, EitherTypeNotFound>
	do {
		ret = try .success(container.decode(Thing.self))
	} catch (let err as DecodingError) {
		ret = .failure(EitherTypeNotFound(type: type, error: err))
	} catch (let err) {
        ret = .failure(EitherTypeNotFound(
            type: type,
            error: DecodingError.typeMismatch(
                Thing.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: String(describing: err),
                    underlyingError: err
                )
            )
        ))
	}
	return ret
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

		let attempts = [
            try decode(A.self, from: container).map { Either.a($0) },
			try decode(B.self, from: container).map { Either.b($0) }]

		let maybeVal: Either<A, B>? = attempts
            .lazy
			.compactMap { $0.value }
			.first

		guard let val = maybeVal else {
            let individualFailures = attempts.map { $0.error }.compactMap { $0 }

            throw EitherDecodeNoTypesMatchedError(
                codingPath: decoder.codingPath,
                individualTypeFailures: individualFailures
            )
		}

		self = val
	}
}

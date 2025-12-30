//
//  Response.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Response Object"
    ///
    /// See [OpenAPI Response Object](https://spec.openapis.org/oas/v3.2.0.html#response-object).
    public struct Response: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        public var summary: String?
        public var description: String?

        public var headers: Header.Map?
        /// An empty Content map will be omitted from encoding.
        public var content: Content.Map
        /// An empty Link map will be omitted from encoding.
        public var links: Link.Map

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        public init(
            summary: String? = nil,
            description: String? = nil,
            headers: Header.Map? = nil,
            content: Content.Map = [:],
            links: Link.Map = [:],
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            self.headers = headers
            self.content = content
            self.links = links
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = [
                // If summary is non-nil, the document must be OAS version 3.2.0 or greater
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Response", fieldName: "summary", value: summary, minimumVersion: .v3_2_0),
                // If description is nil, the document must be OAS version 3.2.0 or greater
                notOptionalVersionWarning(fieldName: "description", value: description, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }
    }
}

extension OpenAPI.Response: Equatable {
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.summary == rhs.summary
        && lhs.description == rhs.description
        && lhs.headers == rhs.headers
        && lhs.content == rhs.content
        && lhs.links == rhs.links
        && lhs.vendorExtensions == rhs.vendorExtensions
    }
}

fileprivate func notOptionalVersionWarning<Subject>(fieldName: String, value: Subject?, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
    guard value == nil else { return nil }

    return OpenAPI.Document.ConditionalWarnings.version(
        lessThan: minimumVersion,
        doesNotAllowOptional: "The Response \(fieldName) field"
    )
}

extension OpenAPI.Response {
    public typealias Map = OrderedDictionary<StatusCode, Either<OpenAPI.Reference<OpenAPI.Response>, OpenAPI.Response>>
}

extension OrderedDictionary where Key == OpenAPI.Response.StatusCode {
    /// This subscript makes it possible to disambiguate the call to the integer-based
    /// (indexed) subscript and the key-based (hashed) subscript of the `OrderedDictionary`
    /// for `StatusCode` keys.
    ///
    /// A problem of ambiguity arises from the fact that `StatusCode` is `ExpressibleByIntegerLiteral`
    /// so both `OrderedDictionary` unlabled subscript accessors are applicable.
    ///
    /// **Example**:
    ///
    ///     let successfulDeleteOperation = document.paths["/hello/world"]?.delete?.responses[status: 204]
    ///
    public subscript(status status: OpenAPI.Response.StatusCode) -> Value? {
        get {
            return self[status]
        }
        set {
            self[status] = newValue
        }
    }
}

// MARK: `Either` convenience methods
extension Either where A == OpenAPI.Reference<OpenAPI.Response>, B == OpenAPI.Response {

    public static func response(
        summary: String? = nil,
        description: String? = nil,
        headers: OpenAPI.Header.Map? = nil,
        content: OpenAPI.Content.Map = [:],
        links: OpenAPI.Link.Map = [:]
    ) -> Self {
        return .b(
            .init(
                description: description,
                headers: headers,
                content: content,
                links: links
            )
        )
    }
}

// MARK: - Describable
extension OpenAPI.Response: OpenAPISummarizable {
    public func overriddenNonNil(description: String?) -> OpenAPI.Response {
        guard let description = description else { return self }
        var response = self
        response.description = description
        return response
    }

    public func overriddenNonNil(summary: String?) -> OpenAPI.Response {
        guard let summary = summary else { return self }
        var response = self
        response.summary = summary
        return response
    }
}

// MARK: - Codable

extension OpenAPI.Response {
    internal enum CodingKeys: ExtendableCodingKey {
        case summary
        case description
        case headers
        case content
        case links
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .summary,
                .description,
                .headers,
                .content,
                .links
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "summary":
                self = .summary
            case "description":
                self = .description
            case "headers":
                self = .headers
            case "content":
                self = .content
            case "links":
                self = .links
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .summary:
                return "summary"
            case .description:
                return "description"
            case .headers:
                return "headers"
            case .content:
                return "content"
            case .links:
                return "links"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Response: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(summary, forKey: .summary)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(headers, forKey: .headers)

        if !content.isEmpty {
            try container.encode(content, forKey: .content)
        }

        if !links.isEmpty {
            try container.encode(links, forKey: .links)
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Response: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            summary = try container.decodeIfPresent(String.self, forKey: .summary)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            headers = try container.decodeIfPresent(OpenAPI.Header.Map.self, forKey: .headers)
            content = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content) ?? [:]
            links = try container.decodeIfPresent(OpenAPI.Link.Map.self, forKey: .links) ?? [:]

            vendorExtensions = try Self.extensions(from: decoder)

            conditionalWarnings = [
                // If summary is non-nil, the document must be OAS version 3.2.0 or greater
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Response", fieldName: "summary", value: summary, minimumVersion: .v3_2_0),
                // If description is nil, the document must be OAS version 3.2.0 or greater
                notOptionalVersionWarning(fieldName: "description", value: description, minimumVersion: .v3_2_0)
            ].compactMap { $0 }

        } catch let error as GenericError {

            throw OpenAPI.Error.Decoding.Response(error)
        } catch let error as EitherDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Response(error)
        } catch let error as DecodingError {

            throw OpenAPI.Error.Decoding.Response(error)
        }
    }
}

extension OpenAPI.Response: Validatable {}

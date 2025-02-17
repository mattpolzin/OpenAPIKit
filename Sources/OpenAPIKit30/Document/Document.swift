//
//  Document.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 1/13/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// The root of an OpenAPI 3.0 document.
    /// 
    /// See [OpenAPI Specification](https://spec.openapis.org/oas/v3.0.4.html).
    ///
    /// An OpenAPI Document can say a _lot_ about the API it describes.
    /// A read-through of the specification is highly recommended because
    /// OpenAPIKit stays intentionally close to the naming and structure
    /// layed out by the Specification -- it goes without saying that the encoded
    /// JSON or YAML produced by OpenAPIKit conforms to the specification
    /// exactly.
    ///
    /// A document is decoded in the normal fashion for `Codable` types:
    ///
    ///     let data: Data = ...
    ///     let document = try JSONDecoder().decode(OpenAPI.Document.self, data)
    ///
    /// At this point, all of the information exposed by the decoded documentation is available via
    /// OpenAPIKit types that largely follow the structure and naming conventions of the specification.
    ///
    /// If the documentation exists within a single file (no JSON references to other files) and there are
    /// no cyclic JSON references, you can dereference the documentation to remove the need to follow
    /// JSON references while traversing the documentation.
    ///
    ///     let dereferencedDocument = try document.locallyDereferenced()
    ///
    /// See the documentation on `OpenAPI.Document.locallyDereferenced()` for more.
    ///
    /// At this point all references have been removed and replaced with inline documentation
    /// components. You can "resolve" the documentation to get an even more concise
    /// representation; this is no longer an OpenAPI representation, but rather an alternative
    /// view OpenAPIKit provides that can make analyzing and traversing documentation
    /// substantially easier for certain use-cases.
    ///
    ///     let resolvedDocument = dereferencedDocument.resolved()
    ///
    /// See the documentation on `DereferencedDocument.resolved()` for more.
    ///
    public struct Document: Equatable, CodableVendorExtendable {
        /// OpenAPI Spec "openapi" field.
        ///
        /// OpenAPIKit only explicitly supports versions that can be found in
        /// the `Version` enum. Other versions may or may not be decodable
        /// by OpenAPIKit to a certain extent.
        public var openAPIVersion: Version

        /// Information about the API described by this OpenAPI Document.
        ///
        /// Licensing, Terms of Service, contact information, API version (the
        /// version of the API this document describes, not the OpenAPI
        /// Specification version), etc.
        public var info: Info

        /// An array of Server Objects, which provide connectivity information
        /// to a target server.
        ///
        /// If the servers property is not provided, or is an
        /// empty array, the default value is a Server Object with a url value of
        /// "/".
        ///
        /// - Important: If you want to get all servers mentioned anywhere in
        ///     the whole document (including servers that appear in path items
        ///     or operations but not at the root document level), use the
        ///     `allServers` property instead.
        public var servers: [Server]

        /// All paths defined by this API. This property maps the path of each
        /// route (`OpenAPI.Path`) to the documentation for that route
        /// (`OpenAPI.PathItem`).
        ///
        /// See the `routes` property for an array of equatable `Path`/`PathItem`
        /// pairs.
        public var paths: PathItem.Map

        /// Storage for components that need to be referenced elsewhere in the
        /// OpenAPI Document using `JSONReferences`.
        ///
        /// Storing components here can be in the interest of being explicit about
        /// the fact that the components are always the same (such as an
        /// "Unauthorized" `Response` definition used on all endpoints) or it might
        /// just be practical to put things here and reference them elsewhere to
        /// cut down on the overall size of the document.
        ///
        /// If your document is defined in Swift then this is a less beneficial way to
        /// share definitions than to just use the same Swift value multiple times, but
        /// you still might want to consider using the Components Object for its impact
        /// on the JSON/YAML structure of your document once encoded.
        public var components: Components

        /// A declaration of which security mechanisms can be used across the API.
        ///
        /// The list of values includes alternative security requirement objects that can
        /// be used. Only one of the security requirement objects need to be satisfied
        /// to authorize a request. Individual operations can override this definition.
        ///
        /// To make security optional, an empty security requirement can be included
        /// in the array.
        ///
        /// - Important: The OpenAPI Specification defines Security Requirement
        ///     Object keys as being `String` values corresponding to entries in
        ///     the Components Object.
        ///
        ///     OpenAPIKit has a type capable of representing that: The `JSONReference`.
        ///     For that reason, OpenAPIKit defines keys in security requirement objects as
        ///     explicit references to entries in the Components Object instead of `String`
        ///     values.
        public var security: [SecurityRequirement]

        /// A list of tags used by the specification with additional metadata.
        ///
        /// The order of the tags can be used to reflect on their order by the parsing tools.
        /// Not all tags that are used by Operation Objects must be declared at the document
        /// level.
        ///
        /// - Important: Each tag name in the list MUST be unique.
        public var tags: [Tag]?

        /// Additional external documentation.
        public var externalDocs: ExternalDocumentation?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            openAPIVersion: Version = .v3_0_4,
            info: Info,
            servers: [Server],
            paths: PathItem.Map,
            components: Components,
            security: [SecurityRequirement] = [],
            tags: [Tag]? = nil,
            externalDocs: ExternalDocumentation? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.servers = servers
            self.paths = paths
            self.components = components
            self.security = security
            self.tags = tags
            self.externalDocs = externalDocs
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI.Document {
    /// Create a new OpenAPI Document with
    /// all paths not passign the given predicate
    /// removed.
    public func filteringPaths(with predicate: (OpenAPI.Path) -> Bool) -> OpenAPI.Document {
        let filteredPaths = paths.filteringPaths(with: predicate)
        return OpenAPI.Document(
            openAPIVersion: openAPIVersion,
            info: info,
            servers: servers,
            paths: filteredPaths,
            components: components,
            security: security,
            tags: tags,
            externalDocs: externalDocs,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPI.Document {
    /// A `Route` is the combination of a path (where the route lives)
    /// and a path item (the definition of the route).
    public struct Route: Equatable {
        public let path: OpenAPI.Path
        public let pathItem: OpenAPI.PathItem

        public init(
            path: OpenAPI.Path,
            pathItem: OpenAPI.PathItem
        ) {
            self.path = path
            self.pathItem = pathItem
        }
    }

    /// Get all routes for this document.
    ///
    /// - Returns: An Array of `Routes` with the path
    ///     and the definition of the route.
    public var routes: [Route] {
        return paths.compactMap { (path, pathItemRef) in
            components[pathItemRef].map { .init(path: path, pathItem: $0) }
        }
    }

    /// Retrieve an array of all Operation Ids defined by
    /// this API. These Ids are guaranteed to be unique by
    /// the OpenAPI Specification.
    ///
    /// The ordering is not necessarily significant, but it will
    /// be the order in which each operation is occurred within
    /// each path, traversed in the order the paths appear in
    /// the document.
    ///
    /// See [Operation Object](https://spec.openapis.org/oas/v3.0.4.html#operation-object) in the specifcation.
    ///
    public var allOperationIds: [String] {
        return paths.values
            .compactMap { components[$0] }
            .flatMap { $0.endpoints }
            .compactMap { $0.operation.operationId }
    }

    /// All servers referenced anywhere in the whole document.
    ///
    /// This property contains all servers defined at any level the document
    /// and therefore may or may not contain servers not found in the
    /// root servers array.
    ///
    /// The `servers` property on `OpenAPI.Document`, by contrast, contains
    /// servers that are applicable to all paths and operations that
    /// do not define their own `serves` array to override the root array.
    ///
    /// - Important: For the purposes of returning one of each `Server`,
    ///     two servers are considered identical if they have the same `url`
    ///     and `variables`. Differing `description` properties for
    ///     otherwise identical servers are considered to be two ways to
    ///     describe the same server. `vendorExtensions` are also
    ///     ignored when determining server uniqueness.
    ///
    ///     The first `Server` encountered will be used, so if the only
    ///     difference between a server at the root document level and
    ///     one in an `Operation`'s override of the servers array is the
    ///     description, the description of the `Server` returned by this
    ///     property will be that of the root document definition.
    ///
    public var allServers: [OpenAPI.Server] {
        // We hash `Variable` without its
        // `description` or `vendorExtensions`.
        func hash(variable: OpenAPI.Server.Variable, into hasher: inout Hasher) {
            hasher.combine(variable.enum)
            hasher.combine(variable.default)
        }

        // We hash `Server` without its `description` or
        // `vendorExtensions`.
        func hash(server: OpenAPI.Server, into hasher: inout Hasher) {
            hasher.combine(server.urlTemplate)
            for (key, value) in server.variables {
                hasher.combine(key)
                hash(variable: value, into: &hasher)
            }
        }

        func hash(for server: OpenAPI.Server) -> Int {
            var hasher = Hasher()
            hash(server: server, into: &hasher)
            return hasher.finalize()
        }

        var collectedServers = servers
        var seenHashes = Set(servers.map(hash(for:)))

        func insertUniquely(server: OpenAPI.Server) {
            let serverHash = hash(for: server)
            if !seenHashes.contains(serverHash) {
                seenHashes.insert(serverHash)
                collectedServers.append(server)
            }
        }

        for pathItem in paths.values {
            guard let pathItemValue = components[pathItem] else { continue }

            let pathItemServers = pathItemValue.servers ?? []
            pathItemServers.forEach(insertUniquely)

            let endpointServers = pathItemValue.endpoints.flatMap { $0.operation.servers ?? [] }
            endpointServers.forEach(insertUniquely)
        }

        return collectedServers
    }

    /// All Tags used anywhere in the document.
    ///
    /// The tags stored in the `OpenAPI.Document.tags`
    /// property need not contain all tags used anywhere in
    /// the document. This property is comprehensive.
    public var allTags: Set<String> {
        return Set(
            (tags ?? []).map { $0.name }
            + paths.values.compactMap { components[$0] }
                .flatMap { $0.endpoints }
                .flatMap { $0.operation.tags ?? [] }
        )
    }
}

public enum ExternalDereferenceDepth {
    case iterations(Int)
    case full
}

extension ExternalDereferenceDepth: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .iterations(value)
    }
}

extension OpenAPI.Document {
    /// Create a locally-dereferenced OpenAPI
    /// Document.
    ///
    /// This function assumes all references are
    /// local to the same file. If you want to resolve
    /// remote references as well, call `externallyDereference()`
    /// first and then locally dereference the result.
    ///
    /// A dereferenced document contains no
    /// `JSONReferences`. All components have been
    /// inlined.
    ///
    /// Dereferencing the document is a necessary
    /// step toward **resolving** the document, which
    /// exposes canonical representations of routes and
    /// endpoints.
    ///
    /// - Important: Local dereferencing will `throw` if any
    ///     `JSONReferences` point to other files or to
    ///     locations within the same file other than the
    ///     Components Object. It will also fail if any components
    ///     are missing from the Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public func locallyDereferenced() throws -> DereferencedDocument {
        return try DereferencedDocument(self)
    }

    /// Load all remote references into the document. A remote reference is one
    /// that points to another file rather than a location within the
    /// same file.
    ///
    /// This function will load remote references into the Components object
    /// and replace the remote reference with a local reference to that component.
    /// No local references are modified or resolved by this function. You can
    /// call `locallyDereferenced()` on the externally dereferenced document if
    /// you want to also remove local references by inlining all of them.
    ///
    /// Externally dereferencing a document requires that you provide both a
    /// function that produces a `OpenAPI.ComponentKey` for any given remote
    /// file URI and also a function that loads and decodes the data found in
    /// that remote file. The latter is less work than it may sound like because
    /// the function is told what Decodable thing it wants, so you really just
    /// need to decide what decoder to use and provide the file data to that
    /// decoder. See `ExternalLoader` documentation for details.
    @discardableResult
    public mutating func externallyDereference<Loader: ExternalLoader>(with loader: Loader.Type, depth: ExternalDereferenceDepth = .iterations(1), context: [Loader.Message] = []) async throws -> [Loader.Message] {
        if case let .iterations(number) = depth,
           number <= 0 {
            return context
        }

        let oldPaths = paths

        async let (newPaths, c1, m1) = oldPaths.externallyDereferenced(with: loader)

        paths = try await newPaths
        try await components.merge(c1)

        let m2 = try await components.externallyDereference(with: loader, depth: depth)

        return try await context + m1 + m2
    }
}

extension OpenAPI {
    /// OpenAPI Spec "Security Requirement Object"
    ///
    /// If the security scheme is of type "oauth2" or "openIdConnect",
    /// then the value is a list of scope names required for the execution.
    /// For other security scheme types, the array MUST be empty.
    ///
    /// Multiple entries in this dictionary indicate all schemes named are
    /// required on the same request.
    ///
    /// See [OpenAPI Security Requirement Object](https://spec.openapis.org/oas/v3.0.4.html#security-requirement-object).
    public typealias SecurityRequirement = [JSONReference<SecurityScheme>: [String]]
}

extension OpenAPI.Document {
    /// The OpenAPI Specification version.
    ///
    /// OpenAPIKit only explicitly supports versions that can be found in
    /// this enum. Other versions may or may not be decodable by
    /// OpenAPIKit to a certain extent.
    ///
    ///**IMPORTANT**: Although the `v3_0_x` case supports arbitrary
    /// patch versions, only _known_ patch versions are decodable. That is, if the OpenAPI
    /// specification releases a new patch version, OpenAPIKit will see a patch version release
    /// explicitly supports decoding documents of that new patch version before said version will
    /// succesfully decode as the `v3_0_x` case.
  public enum Version: RawRepresentable, Equatable, Codable {
        case v3_0_0
        case v3_0_1
        case v3_0_2
        case v3_0_3
        case v3_0_4
        case v3_0_x(x: Int)

        public init?(rawValue: String) {
            switch rawValue {
            case "3.0.0": self = .v3_0_0
            case "3.0.1": self = .v3_0_1
            case "3.0.2": self = .v3_0_2
            case "3.0.3": self = .v3_0_3
            case "3.0.4": self = .v3_0_4
            default:
                let components = rawValue.split(separator: ".")
                guard components.count == 3 else {
                    return nil
                }
                guard components[0] == "3", components[1] == "0" else {
                    return nil
                }
                guard let patchVersion = Int(components[2], radix: 10) else {
                    return nil
                }
                // to support newer versions released in the future without a breaking
                // change to the enumeration, bump the upper limit here to e.g. 5 or 6
                // or 9:
                guard patchVersion > 4 && patchVersion <= 4 else {
                  return nil
                }
                self = .v3_0_x(x: patchVersion)
            }
        }

        public var rawValue: String {
            switch self {
            case .v3_0_0: return "3.0.0"
            case .v3_0_1: return "3.0.1"
            case .v3_0_2: return "3.0.2"
            case .v3_0_3: return "3.0.3"
            case .v3_0_4: return "3.0.4"
            case .v3_0_x(x: let x): return "3.0.\(x)"
            }
        }
    }
}

// MARK: - Codable

extension OpenAPI.Document: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(openAPIVersion, forKey: .openAPIVersion)
        try container.encode(info, forKey: .info)

        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)

        try container.encodeIfPresent(tags, forKey: .tags)

        if !servers.isEmpty {
            try container.encode(servers, forKey: .servers)
        }

        // A real mess here because we've got an Array of non-string-keyed
        // Dictionaries.
        if !security.isEmpty {
            try encodeSecurity(requirements: security, to: &container, forKey: .security)
        }

        try container.encode(paths, forKey: .paths)

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }

        if !components.isEmpty {
            try container.encode(components, forKey: .components)
        }
    }
}

extension OpenAPI.Document: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            openAPIVersion = try container.decode(OpenAPI.Document.Version.self, forKey: .openAPIVersion)
            info = try container.decode(OpenAPI.Document.Info.self, forKey: .info)
            servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers) ?? []

            let components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents
            self.components = components

            let paths = try container.decode(OpenAPI.PathItem.Map.self, forKey: .paths)
            self.paths = paths
            try validateSecurityRequirements(in: paths, against: components)

            security = try decodeSecurityRequirements(from: container, forKey: .security, given: components) ?? []
            tags = try container.decodeIfPresent([OpenAPI.Tag].self, forKey: .tags)
            externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)
            vendorExtensions = try Self.extensions(from: decoder)

        } catch let error as OpenAPI.Error.Decoding.Path {

            throw OpenAPI.Error.Decoding.Document(error)
        } catch let error as InconsistencyError {

            throw OpenAPI.Error.Decoding.Document(error)
        } catch let error as DecodingError {

            throw OpenAPI.Error.Decoding.Document(error)
        } catch let error as EitherDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Document(error)
        }
    }
}

extension OpenAPI.Document {
    internal enum CodingKeys: ExtendableCodingKey {
        case openAPIVersion
        case info
        case servers
        case paths
        case components
        case security
        case tags
        case externalDocs
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .openAPIVersion,
                .info,
                .servers,
                .paths,
                .components,
                .security,
                .tags,
                .externalDocs
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "openapi":
                self = .openAPIVersion
            case "info":
                self = .info
            case "servers":
                self = .servers
            case "paths":
                self = .paths
            case "components":
                self = .components
            case "security":
                self = .security
            case "tags":
                self = .tags
            case "externalDocs":
                self = .externalDocs
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .openAPIVersion:
                return "openapi"
            case .info:
                return "info"
            case .servers:
                return "servers"
            case .paths:
                return "paths"
            case .components:
                return "components"
            case .security:
                return "security"
            case .tags:
                return "tags"
            case .externalDocs:
                return "externalDocs"
            case .extended(let key):
                return key
            }
        }
    }
}

internal func encodeSecurity<CodingKeys: CodingKey>(requirements security: [OpenAPI.SecurityRequirement], to container: inout KeyedEncodingContainer<CodingKeys>, forKey key: CodingKeys) throws {
    // A real mess here because we've got an Array of non-string-keyed
    // Dictionaries.
    var securityContainer = container.nestedUnkeyedContainer(forKey: key)
    for securityRequirement in security {
        let securityKeysAndValues = securityRequirement
            .compactMap { keyValue in keyValue.key.name.map { ($0, keyValue.value) } }
        let securityStringKeyedDict = Dictionary(
            securityKeysAndValues,
            uniquingKeysWith: { $1 }
        )
        try securityContainer.encode(securityStringKeyedDict)
    }
}

internal func decodeSecurityRequirements<CodingKeys: CodingKey>(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys, given optionalComponents: OpenAPI.Components?) throws -> [OpenAPI.SecurityRequirement]? {
    // A real mess here because we've got an Array of non-string-keyed
    // Dictionaries.
    if container.contains(key) {
        var securityContainer = try container.nestedUnkeyedContainer(forKey: key)

        var securityRequirements = [OpenAPI.SecurityRequirement]()
        while !securityContainer.isAtEnd {
            let securityStringKeyedDict = try securityContainer.decode([String: [String]].self)

            // convert to JSONReference keys
            let securityKeysAndValues = securityStringKeyedDict.map { (key, value) in
                (
                    key: JSONReference<OpenAPI.SecurityScheme>.component(named: key),
                    value: value
                )
            }

            if let components = optionalComponents {
                // check each key for validity against components.
                let foundInComponents = { (ref: JSONReference<OpenAPI.SecurityScheme>) -> Bool in
                    return (try? components.contains(ref)) ?? false
                }
                guard securityKeysAndValues.map({ $0.key }).allSatisfy(foundInComponents) else {
                    throw InconsistencyError(
                        subjectName: key.stringValue,
                        details: "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary",
                        codingPath: container.codingPath + [key]
                    )
                }
            }

            securityRequirements.append(Dictionary(securityKeysAndValues, uniquingKeysWith: { $1 }))
        }

        return securityRequirements
    }

    return nil
}

internal func validateSecurityRequirements(in paths: OpenAPI.PathItem.Map, against components: OpenAPI.Components) throws {
    for (path, pathItem) in paths {
        guard let pathItemValue = components[pathItem] else { continue }

        for endpoint in pathItemValue.endpoints {
            if let securityRequirements = endpoint.operation.security {
                try validate(
                    securityRequirements: securityRequirements,
                    at: path,
                    for: endpoint.method,
                    against: components
                )
            }
        }
    }
}

internal func validate(securityRequirements: [OpenAPI.SecurityRequirement], at path: OpenAPI.Path, for verb: OpenAPI.HttpMethod, against components: OpenAPI.Components) throws {
    let securitySchemes = securityRequirements.flatMap { $0.keys }

    for securityScheme in securitySchemes {
        guard components[securityScheme] != nil else {
            let schemeKey = securityScheme.name ?? securityScheme.absoluteString
            let keys = [
                "paths",
                path.rawValue,
                verb.rawValue.lowercased(),
                "security",
                schemeKey
            ]
            .map(AnyCodingKey.init(stringValue:))

            throw InconsistencyError(
                subjectName: schemeKey,
                details: "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary",
                codingPath: keys
            )
        }
    }
}

extension OpenAPI.Document: Validatable {}
extension OpenAPI.Document.Version: Validatable {}

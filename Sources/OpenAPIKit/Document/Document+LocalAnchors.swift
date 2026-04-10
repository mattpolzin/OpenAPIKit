//
//  Document+LocalAnchors.swift
//

import OpenAPIKitCore

extension OpenAPI.Document {
    public struct DuplicateAnchorError: Swift.Error, Equatable, CustomStringConvertible {
        public let name: String

        public init(name: String) {
            self.name = name
        }

        public var description: String {
            "Encountered multiple JSON Schema $anchor definitions named '\(name)' while preparing a locally dereferenced document. OpenAPIKit cannot determine which schema '#\(name)' should resolve to."
        }

        public var localizedDescription: String {
            description
        }
    }

    internal func locallyDereferenceableComponents() throws -> OpenAPI.Components {
        var components = self.components
        var localAnchors = LocalAnchorCollection()

        collectLocalAnchorSchemas(into: &localAnchors)

        if let duplicateAnchor = localAnchors.duplicateAnchorNames.sorted().first {
            throw DuplicateAnchorError(name: duplicateAnchor)
        }

        for (anchor, schema) in localAnchors.schemasByName {
            components.registerLocalAnchorSchema(schema, named: anchor)
        }

        return components
    }

    private func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        components.collectLocalAnchorSchemas(into: &localAnchors)

        for pathItem in paths.values {
            guard case .b(let pathItem) = pathItem else {
                continue
            }
            pathItem.collectLocalAnchorSchemas(into: &localAnchors)
        }

        for webhook in webhooks.values {
            guard case .b(let pathItem) = webhook else {
                continue
            }
            pathItem.collectLocalAnchorSchemas(into: &localAnchors)
        }
    }
}

fileprivate struct LocalAnchorCollection {
    var schemasByName: OrderedDictionary<String, JSONSchema> = [:]
    var duplicateAnchorNames: Set<String> = []

    mutating func record(_ schema: JSONSchema) {
        guard let anchor = schema.anchor else {
            return
        }

        if schemasByName[anchor] == nil {
            schemasByName[anchor] = schema
        } else {
            duplicateAnchorNames.insert(anchor)
        }
    }
}

extension OpenAPI.Components {
    internal static let localAnchorVendorExtension = "x-openapikit-local-anchor"

    internal mutating func registerLocalAnchorSchema(
        _ schema: JSONSchema,
        named anchor: String
    ) {
        var collisionIndex = 0

        while true {
            let componentKey = Self.localAnchorComponentKey(
                for: anchor,
                collisionIndex: collisionIndex
            )

            if let existingSchema = schemas[componentKey] {
                if existingSchema.localAnchorName == anchor {
                    return
                }

                collisionIndex += 1
                continue
            }

            schemas[componentKey] = schema.markedAsLocalAnchor(named: anchor)
            return
        }
    }

    internal func localAnchorSchema(named anchor: String) -> JSONSchema? {
        var collisionIndex = 0

        while true {
            let componentKey = Self.localAnchorComponentKey(
                for: anchor,
                collisionIndex: collisionIndex
            )

            guard let schema = schemas[componentKey] else {
                return nil
            }

            if schema.localAnchorName == anchor {
                return schema.removingLocalAnchorMarker()
            }

            collisionIndex += 1
        }
    }

    internal static func localAnchorComponentKey(
        for anchor: String,
        collisionIndex: Int
    ) -> OpenAPI.ComponentKey {
        let encodedAnchor = anchor.utf8
            .flatMap(Self.hexDigits(for:))
            .map(String.init)
            .joined()
        let rawValue = "__openapikit_anchor_\(collisionIndex)_\(encodedAnchor)"

        return OpenAPI.ComponentKey(rawValue: rawValue)!
    }

    private static func hexDigits(for byte: UInt8) -> [Character] {
        let digits = Array("0123456789abcdef")
        return [
            digits[Int(byte / 16)],
            digits[Int(byte % 16)]
        ]
    }

    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for schema in schemas.values {
            schema.collectLocalAnchorSchemas(into: &localAnchors)
        }

        for parameter in parameters.values {
            switch parameter {
            case .a:
                continue
            case .b(let parameter):
                parameter.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for request in requestBodies.values {
            switch request {
            case .a:
                continue
            case .b(let request):
                request.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for response in responses.values {
            switch response {
            case .a:
                continue
            case .b(let response):
                response.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for header in headers.values {
            switch header {
            case .a:
                continue
            case .b(let header):
                header.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for pathItem in pathItems.values {
            pathItem.collectLocalAnchorSchemas(into: &localAnchors)
        }

        for callbacks in callbacks.values {
            switch callbacks {
            case .a:
                continue
            case .b(let callbacks):
                callbacks.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for mediaType in mediaTypes.values {
            switch mediaType {
            case .a:
                continue
            case .b(let mediaType):
                mediaType.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }
    }
}

extension OpenAPI.PathItem {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for parameter in parameters {
            switch parameter {
            case .a:
                continue
            case .b(let parameter):
                parameter.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for endpoint in endpoints {
            endpoint.operation.collectLocalAnchorSchemas(into: &localAnchors)
        }
    }
}

extension OpenAPI.Operation {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for parameter in parameters {
            switch parameter {
            case .a:
                continue
            case .b(let parameter):
                parameter.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        if case .some(.b(let requestBody)) = requestBody {
            requestBody.collectLocalAnchorSchemas(into: &localAnchors)
        }

        for response in responses.values {
            switch response {
            case .a:
                continue
            case .b(let response):
                response.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }

        for callbacks in callbacks.values {
            switch callbacks {
            case .a:
                continue
            case .b(let callbacks):
                callbacks.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }
    }
}

extension OpenAPI.Callbacks {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for pathItem in values {
            switch pathItem {
            case .a:
                continue
            case .b(let pathItem):
                pathItem.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }
    }
}

extension OpenAPI.Parameter {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        switch schemaOrContent {
        case .a(let schemaContext):
            schemaContext.collectLocalAnchorSchemas(into: &localAnchors)
        case .b(let content):
            content.collectLocalAnchorSchemas(into: &localAnchors)
        }
    }
}

extension OpenAPI.Parameter.SchemaContext {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        switch schema {
        case .a:
            break
        case .b(let schema):
            schema.collectLocalAnchorSchemas(into: &localAnchors)
        }
    }
}

extension OpenAPI.Request {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        content.collectLocalAnchorSchemas(into: &localAnchors)
    }
}

extension OpenAPI.Response {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        headers?.collectLocalAnchorSchemas(into: &localAnchors)
        content.collectLocalAnchorSchemas(into: &localAnchors)
    }
}

extension OpenAPI.Header {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        switch schemaOrContent {
        case .a(let schemaContext):
            schemaContext.collectLocalAnchorSchemas(into: &localAnchors)
        case .b(let content):
            content.collectLocalAnchorSchemas(into: &localAnchors)
        }
    }
}

extension OrderedDictionary where Key == OpenAPI.ContentType, Value == Either<OpenAPI.Reference<OpenAPI.Content>, OpenAPI.Content> {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for content in values {
            switch content {
            case .a:
                continue
            case .b(let content):
                content.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }
    }
}

extension OpenAPI.Content {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        schema?.collectLocalAnchorSchemas(into: &localAnchors)
        itemSchema?.collectLocalAnchorSchemas(into: &localAnchors)

        switch encoding {
        case .a(let encodingMap):
            for encoding in encodingMap.values {
                encoding.collectLocalAnchorSchemas(into: &localAnchors)
            }
        case .b(let positionalEncoding):
            positionalEncoding.collectLocalAnchorSchemas(into: &localAnchors)
        case .none:
            break
        }
    }
}

extension OpenAPI.Content.Encoding {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        headers?.collectLocalAnchorSchemas(into: &localAnchors)
    }
}

extension OpenAPI.Content.PositionalEncoding {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for encoding in prefixEncoding {
            encoding.collectLocalAnchorSchemas(into: &localAnchors)
        }

        itemEncoding?.collectLocalAnchorSchemas(into: &localAnchors)
    }
}

extension OrderedDictionary where Key == String, Value == Either<OpenAPI.Reference<OpenAPI.Header>, OpenAPI.Header> {
    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        for header in values {
            switch header {
            case .a:
                continue
            case .b(let header):
                header.collectLocalAnchorSchemas(into: &localAnchors)
            }
        }
    }
}

extension JSONSchema {
    fileprivate var localAnchorName: String? {
        vendorExtensions[OpenAPI.Components.localAnchorVendorExtension]?.value as? String
    }

    fileprivate func markedAsLocalAnchor(named anchor: String) -> JSONSchema {
        var extensions = vendorExtensions
        extensions[OpenAPI.Components.localAnchorVendorExtension] = .init(anchor)
        return with(vendorExtensions: extensions)
    }

    fileprivate func removingLocalAnchorMarker() -> JSONSchema {
        guard localAnchorName != nil else {
            return self
        }

        var extensions = vendorExtensions
        extensions.removeValue(forKey: OpenAPI.Components.localAnchorVendorExtension)
        return with(vendorExtensions: extensions)
    }

    fileprivate func collectLocalAnchorSchemas(
        into localAnchors: inout LocalAnchorCollection
    ) {
        localAnchors.record(self)

        for definition in defs.values {
            definition.collectLocalAnchorSchemas(into: &localAnchors)
        }

        switch value {
        case .object(_, let objectContext):
            for property in objectContext.properties.values {
                property.collectLocalAnchorSchemas(into: &localAnchors)
            }

            if case .b(let additionalProperties) = objectContext.additionalProperties {
                additionalProperties.collectLocalAnchorSchemas(into: &localAnchors)
            }

        case .array(_, let arrayContext):
            arrayContext.items?.collectLocalAnchorSchemas(into: &localAnchors)
            arrayContext.prefixItems?.forEach {
                $0.collectLocalAnchorSchemas(into: &localAnchors)
            }

        case .all(of: let schemas, core: _),
             .one(of: let schemas, core: _),
             .any(of: let schemas, core: _):
            for schema in schemas {
                schema.collectLocalAnchorSchemas(into: &localAnchors)
            }

        case .not(let schema, core: _):
            schema.collectLocalAnchorSchemas(into: &localAnchors)

        case .null,
             .boolean,
             .number,
             .integer,
             .string,
             .reference,
             .fragment:
            break
        }
    }
}

//
//  Document+LocalAnchors.swift
//

import OpenAPIKitCore

extension OpenAPI.Document {
    internal var locallyDereferenceableComponents: OpenAPI.Components {
        var components = self.components
        var anchors: OrderedDictionary<String, JSONSchema> = [:]

        collectLocalAnchorSchemas(into: &anchors)

        for (anchor, schema) in anchors {
            components.registerLocalAnchorSchema(schema, named: anchor)
        }

        return components
    }

    private func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        components.collectLocalAnchorSchemas(into: &anchors)

        for pathItem in paths.values {
            guard case .b(let pathItem) = pathItem else {
                continue
            }
            pathItem.collectLocalAnchorSchemas(into: &anchors)
        }

        for webhook in webhooks.values {
            guard case .b(let pathItem) = webhook else {
                continue
            }
            pathItem.collectLocalAnchorSchemas(into: &anchors)
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
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for schema in schemas.values {
            schema.collectLocalAnchorSchemas(into: &anchors)
        }

        for parameter in parameters.values {
            switch parameter {
            case .a:
                continue
            case .b(let parameter):
                parameter.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for request in requestBodies.values {
            switch request {
            case .a:
                continue
            case .b(let request):
                request.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for response in responses.values {
            switch response {
            case .a:
                continue
            case .b(let response):
                response.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for header in headers.values {
            switch header {
            case .a:
                continue
            case .b(let header):
                header.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for pathItem in pathItems.values {
            pathItem.collectLocalAnchorSchemas(into: &anchors)
        }

        for callbacks in callbacks.values {
            switch callbacks {
            case .a:
                continue
            case .b(let callbacks):
                callbacks.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for mediaType in mediaTypes.values {
            switch mediaType {
            case .a:
                continue
            case .b(let mediaType):
                mediaType.collectLocalAnchorSchemas(into: &anchors)
            }
        }
    }
}

extension OpenAPI.PathItem {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for parameter in parameters {
            switch parameter {
            case .a:
                continue
            case .b(let parameter):
                parameter.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for endpoint in endpoints {
            endpoint.operation.collectLocalAnchorSchemas(into: &anchors)
        }
    }
}

extension OpenAPI.Operation {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for parameter in parameters {
            switch parameter {
            case .a:
                continue
            case .b(let parameter):
                parameter.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        if case .some(.b(let requestBody)) = requestBody {
            requestBody.collectLocalAnchorSchemas(into: &anchors)
        }

        for response in responses.values {
            switch response {
            case .a:
                continue
            case .b(let response):
                response.collectLocalAnchorSchemas(into: &anchors)
            }
        }

        for callbacks in callbacks.values {
            switch callbacks {
            case .a:
                continue
            case .b(let callbacks):
                callbacks.collectLocalAnchorSchemas(into: &anchors)
            }
        }
    }
}

extension OpenAPI.Callbacks {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for pathItem in values {
            switch pathItem {
            case .a:
                continue
            case .b(let pathItem):
                pathItem.collectLocalAnchorSchemas(into: &anchors)
            }
        }
    }
}

extension OpenAPI.Parameter {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        switch schemaOrContent {
        case .a(let schemaContext):
            schemaContext.collectLocalAnchorSchemas(into: &anchors)
        case .b(let content):
            content.collectLocalAnchorSchemas(into: &anchors)
        }
    }
}

extension OpenAPI.Parameter.SchemaContext {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        switch schema {
        case .a:
            break
        case .b(let schema):
            schema.collectLocalAnchorSchemas(into: &anchors)
        }
    }
}

extension OpenAPI.Request {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        content.collectLocalAnchorSchemas(into: &anchors)
    }
}

extension OpenAPI.Response {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        headers?.collectLocalAnchorSchemas(into: &anchors)
        content.collectLocalAnchorSchemas(into: &anchors)
    }
}

extension OpenAPI.Header {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        switch schemaOrContent {
        case .a(let schemaContext):
            schemaContext.collectLocalAnchorSchemas(into: &anchors)
        case .b(let content):
            content.collectLocalAnchorSchemas(into: &anchors)
        }
    }
}

extension OrderedDictionary where Key == OpenAPI.ContentType, Value == Either<OpenAPI.Reference<OpenAPI.Content>, OpenAPI.Content> {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for content in values {
            switch content {
            case .a:
                continue
            case .b(let content):
                content.collectLocalAnchorSchemas(into: &anchors)
            }
        }
    }
}

extension OpenAPI.Content {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        schema?.collectLocalAnchorSchemas(into: &anchors)
        itemSchema?.collectLocalAnchorSchemas(into: &anchors)

        switch encoding {
        case .a(let encodingMap):
            for encoding in encodingMap.values {
                encoding.collectLocalAnchorSchemas(into: &anchors)
            }
        case .b(let positionalEncoding):
            positionalEncoding.collectLocalAnchorSchemas(into: &anchors)
        case .none:
            break
        }
    }
}

extension OpenAPI.Content.Encoding {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        headers?.collectLocalAnchorSchemas(into: &anchors)
    }
}

extension OpenAPI.Content.PositionalEncoding {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for encoding in prefixEncoding {
            encoding.collectLocalAnchorSchemas(into: &anchors)
        }

        itemEncoding?.collectLocalAnchorSchemas(into: &anchors)
    }
}

extension OrderedDictionary where Key == String, Value == Either<OpenAPI.Reference<OpenAPI.Header>, OpenAPI.Header> {
    fileprivate func collectLocalAnchorSchemas(
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        for header in values {
            switch header {
            case .a:
                continue
            case .b(let header):
                header.collectLocalAnchorSchemas(into: &anchors)
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
        into anchors: inout OrderedDictionary<String, JSONSchema>
    ) {
        if let anchor, anchors[anchor] == nil {
            anchors[anchor] = self
        }

        for definition in defs.values {
            definition.collectLocalAnchorSchemas(into: &anchors)
        }

        switch value {
        case .object(_, let objectContext):
            for property in objectContext.properties.values {
                property.collectLocalAnchorSchemas(into: &anchors)
            }

            if case .b(let additionalProperties) = objectContext.additionalProperties {
                additionalProperties.collectLocalAnchorSchemas(into: &anchors)
            }

        case .array(_, let arrayContext):
            arrayContext.items?.collectLocalAnchorSchemas(into: &anchors)

        case .all(of: let schemas, core: _),
             .one(of: let schemas, core: _),
             .any(of: let schemas, core: _):
            for schema in schemas {
                schema.collectLocalAnchorSchemas(into: &anchors)
            }

        case .not(let schema, core: _):
            schema.collectLocalAnchorSchemas(into: &anchors)

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

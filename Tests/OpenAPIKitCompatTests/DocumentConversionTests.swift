//
//  DocumentConversionTests.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

import OpenAPIKit30
import OpenAPIKit
import OpenAPIKitCompat
import XCTest

final class DocumentConversionTests: XCTestCase {
    func test_barebonesDocument() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            openAPIVersion: .v3_0_3,
            info: .init(title: "Hello World", version: "1.0.1"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualOldToNew(newDoc, oldDoc)
        XCTAssertEqual(newDoc.openAPIVersion, .v3_1_0)
    }

    func test_vendorExtensionsOnDoc() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            openAPIVersion: .v3_0_3,
            info: .init(title: "Hello World", version: "1.0.1"),
            servers: [],
            paths: [:],
            components: .noComponents,
            vendorExtensions: ["x-doc": "document"]
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualOldToNew(newDoc, oldDoc)
    }

    func test_fullInfo() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(
                title: "Hello World",
                description: "described",
                termsOfService: URL(string: "https://website.com"),
                contact: .init(name: "Me", url: URL(string: "https://website.com"), email: "me@website.com", vendorExtensions: ["x-test": 1]),
                license: .init(name: "MIT-not", url: URL(string: "https://website.com"), vendorExtensions: ["x-two": 2.0]),
                version: "1.0.1",
                vendorExtensions: ["x-good" : "yeah"]
            ),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualOldToNew(newDoc, oldDoc)
    }

    func test_servers() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [
                .init(
                    url: URL(string: "https://website.com")!,
                    description: "ok",
                    variables: ["x-ok": .init(default: "1.0")],
                    vendorExtensions: ["x-cool": 1.5]
                ),
                .init(
                    urlTemplate: .init(url: URL(string: "https://website.com")!),
                    description: "hi",
                    variables: ["hello": .init(enum: ["1"], default: "1", description: "described", vendorExtensions: ["x-hi": "hello"])],
                    vendorExtensions: ["x-test": 2]
                )
            ],
            paths: [:],
            components: .noComponents
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualOldToNew(newDoc, oldDoc)
    }

    func test_paths() throws {
        let params: OpenAPIKit30.OpenAPI.Parameter.Array = [
            .a(.external(URL(string: "https://welcome.com")!)),
            .a(.component(named: "test")),
            .parameter(.init(name: "test", context: .query, schema: .string))
        ]

        let externalDocs = OpenAPIKit30.OpenAPI.ExternalDocumentation(
            description: "hello",
            url: URL(string: "https://website.com")!,
            vendorExtensions: ["x-hi": 3]
        )

        let request = OpenAPIKit30.OpenAPI.Request(
            description: "describble",
            content: [
                .json: .init(schema: .string, example: "{\"hi\": 1}", encoding: ["utf8": .init()])
            ],
            required: true,
            vendorExtensions: ["x-tend": "ed"]
        )

        let response = OpenAPIKit30.OpenAPI.Response(
            description: "hello",
            headers: ["Content-Type": .header(.init(schema: .string))],
            content: [.json: .init(schema: .string)],
            links: ["link1": .link(operationId: "link1")]
        )

        let callbacks: OpenAPIKit30.OpenAPI.Callbacks = [
            .init(url: URL(string: "https://website.com")!): .init(summary: "hello")
        ]

        let server = OpenAPIKit30.OpenAPI.Server(
            url: URL(string: "https://website.com")!,
            description: "ok",
            variables: ["x-ok": .init(default: "1.0")],
            vendorExtensions: ["x-cool": 1.5]
        )

        let securityRequirement: OpenAPIKit30.OpenAPI.SecurityRequirement = [
            .component(named: "security"): ["hello"]
        ]

        let operation = OpenAPIKit30.OpenAPI.Operation(
            tags: ["hello"],
            summary: "sum",
            description: "described",
            externalDocs: externalDocs,
            operationId: "ident",
            parameters: params,
            requestBody: .request(request),
            responses: [200: .b(response)],
            callbacks: ["callback": .b(callbacks)],
            deprecated: true,
            security: [securityRequirement],
            servers: [server],
            vendorExtensions: ["x-hello": 101]
        )

        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "sum",
                    description: "described",
                    servers: [
                        .init(
                            url: URL(string: "https://website.com")!,
                            description: "ok",
                            variables: ["x-ok": .init(default: "1.0")],
                            vendorExtensions: ["x-cool": 1.5]
                        )
                    ],
                    parameters: [
                        .a(.external(URL(string: "https://welcome.com")!)),
                        .a(.internal(.component(name: "test"))),
                        .parameter(.init(name: "test", context: .query, schema: .string))
                    ],
                    get: operation,
                    put: operation,
                    post: operation,
                    delete: operation,
                    options: operation,
                    head: operation,
                    patch: operation,
                    trace: operation,
                    vendorExtensions: ["x-test": 123]
                )
            ],
            components: .noComponents
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualOldToNew(newDoc, oldDoc)
    }

    // TODO: more tests
}

fileprivate func assertEqualOldToNew(_ newDoc: OpenAPIKit.OpenAPI.Document, _ oldDoc: OpenAPIKit30.OpenAPI.Document) throws {
    // INFO
    XCTAssertEqual(newDoc.info.title, oldDoc.info.title)
    XCTAssertEqual(newDoc.info.version, oldDoc.info.version)
    XCTAssertEqual(newDoc.info.vendorExtensions, oldDoc.info.vendorExtensions)
    XCTAssertEqual(newDoc.info.description, oldDoc.info.description)
    XCTAssertEqual(newDoc.info.contact?.name, oldDoc.info.contact?.name)
    XCTAssertEqual(newDoc.info.contact?.url, oldDoc.info.contact?.url)
    XCTAssertEqual(newDoc.info.contact?.email, oldDoc.info.contact?.email)
    XCTAssertEqual(newDoc.info.contact?.vendorExtensions, oldDoc.info.contact?.vendorExtensions)
    XCTAssertEqual(newDoc.info.termsOfService, oldDoc.info.termsOfService)
    XCTAssertEqual(newDoc.info.license?.name, oldDoc.info.license?.name)
    XCTAssertEqual(newDoc.info.license?.identifier, oldDoc.info.license?.url.map(OpenAPIKit.OpenAPI.Document.Info.License.Identifier.url))
    XCTAssertEqual(newDoc.info.license?.vendorExtensions, oldDoc.info.license?.vendorExtensions)
    XCTAssertNil(newDoc.info.summary)

    // SERVERS
    XCTAssertEqual(newDoc.servers.count, oldDoc.servers.count)
    for (newServer, oldServer) in zip(newDoc.servers, oldDoc.servers) {
        assertEqualOldToNew(newServer, oldServer)
    }

    // PATHS
    XCTAssertEqual(newDoc.paths.count, oldDoc.paths.count)
    for (path, newPathItem) in newDoc.paths {
        let oldPathItem = try XCTUnwrap(oldDoc.paths[path])
        try assertEqualOldToNew(newPathItem.pathItem, oldPathItem) // TODO: switch back to not only testing the non-reference case once OpenAPIKit30 has gained the ability to reference path items as well.
    }

    // COMPONENTS

    // SECURITY

    // TAGS

    // EXTERNAL DOCS

    // VENDOR EXTENSIONS
    XCTAssertEqual(newDoc.vendorExtensions, oldDoc.vendorExtensions)

    // TODO: test the rest of equality.
}

fileprivate func assertEqualOldToNew(_ newServer: OpenAPIKit.OpenAPI.Server, _ oldServer: OpenAPIKit30.OpenAPI.Server) {
    XCTAssertEqual(newServer.urlTemplate, oldServer.urlTemplate)
    XCTAssertEqual(newServer.description, oldServer.description)
    XCTAssertEqual(newServer.vendorExtensions, oldServer.vendorExtensions)
    for (key, newVariable) in newServer.variables {
        let oldVariable = oldServer.variables[key]
        XCTAssertEqual(newVariable.description, oldVariable?.description)
        XCTAssertEqual(newVariable.`enum`, oldVariable?.`enum`)
        XCTAssertEqual(newVariable.`default`, oldVariable?.`default`)
        XCTAssertEqual(newVariable.vendorExtensions, oldVariable?.vendorExtensions)
    }
}

fileprivate func assertEqualOldToNew(_ newParamArray: OpenAPIKit.OpenAPI.Parameter.Array, _ oldParamArray: OpenAPIKit30.OpenAPI.Parameter.Array) {
    for (newParameter, oldParameter) in zip(newParamArray, oldParamArray) {
        switch (newParameter, oldParameter) {
        case (.a(let ref), .a(let ref2)):
            XCTAssertNil(ref.summary)
            XCTAssertNil(ref.description)
            XCTAssertEqual(ref.jsonReference.absoluteString, ref2.absoluteString)
        case (.b(let param), .b(let param2)):
            XCTAssertEqual(param.name, param2.name)
            assertEqualOldToNew(param.context, param2.context)
            XCTAssertEqual(param.description, param2.description)
            XCTAssertEqual(param.deprecated, param2.deprecated)
            XCTAssertEqual(param.vendorExtensions, param2.vendorExtensions)
            XCTAssertEqual(param.required, param2.required)
        default:
            XCTFail("Parameters are not equal because one is a reference and the other is not: \(newParameter)  / \(oldParameter)")
        }
    }
}

fileprivate func assertEqualOldToNew(_ newPathItem: OpenAPIKit.OpenAPI.PathItem?, _ oldPathItem: OpenAPIKit30.OpenAPI.PathItem?) throws {
    guard let newPathItem = newPathItem else {
        XCTAssertNil(oldPathItem)
        return
    }
    let oldPathItem = try XCTUnwrap(oldPathItem)

    XCTAssertEqual(newPathItem.summary, oldPathItem.summary)
    XCTAssertEqual(newPathItem.description, oldPathItem.description)
    if let newServers = newPathItem.servers {
        let oldServers = try XCTUnwrap(oldPathItem.servers)
        for (newServer, oldServer) in zip(newServers, oldServers) {
                assertEqualOldToNew(newServer, oldServer)
        }
    }
    assertEqualOldToNew(newPathItem.parameters, oldPathItem.parameters)
    try assertEqualOldToNew(newPathItem.get, oldPathItem.get)
    try assertEqualOldToNew(newPathItem.put, oldPathItem.put)
    try assertEqualOldToNew(newPathItem.post, oldPathItem.post)
    try assertEqualOldToNew(newPathItem.delete, oldPathItem.delete)
    try assertEqualOldToNew(newPathItem.options, oldPathItem.options)
    try assertEqualOldToNew(newPathItem.head, oldPathItem.head)
    try assertEqualOldToNew(newPathItem.patch, oldPathItem.patch)
    try assertEqualOldToNew(newPathItem.trace, oldPathItem.trace)

    XCTAssertEqual(newPathItem.vendorExtensions, oldPathItem.vendorExtensions)
}

fileprivate func assertEqualOldToNew(_ newParamContext: OpenAPIKit.OpenAPI.Parameter.Context, _ oldParamContext: OpenAPIKit30.OpenAPI.Parameter.Context) {
    switch (newParamContext, oldParamContext) {
    case (.query(required: let req, allowEmptyValue: let empty), .query(required: let req2, allowEmptyValue: let empty2)):
        XCTAssertEqual(req, req2)
        XCTAssertEqual(empty, empty2)
    case (.header(required: let req), .header(required: let req2)):
        XCTAssertEqual(req, req2)
    case (.path, .path):
        break
    case (.cookie(required: let req), .cookie(required: let req2)):
        XCTAssertEqual(req, req2)
    default:
        XCTFail("Parameter contexts are not equal. \(newParamContext)  /   \(oldParamContext)")
    }
}

fileprivate func assertEqualOldToNew(_ newOperation: OpenAPIKit.OpenAPI.Operation?, _ oldOperation: OpenAPIKit30.OpenAPI.Operation?) throws {
    if let newOp = newOperation {
        let oldOp = try XCTUnwrap(oldOperation)

        XCTAssertEqual(newOp.tags, oldOp.tags)
        XCTAssertEqual(newOp.summary, oldOp.summary)
        XCTAssertEqual(newOp.description, oldOp.description)
        try assertEqualOldToNew(newOp.externalDocs, oldOp.externalDocs)
        XCTAssertEqual(newOp.operationId, oldOp.operationId)
        assertEqualOldToNew(newOp.parameters, oldOp.parameters)
        if let newRequest = newOp.requestBody {
            let oldRequest = try XCTUnwrap(oldOp.requestBody)
            switch (newRequest, oldRequest) {
            case (.a(let ref1), .a(let ref2)):
                XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
            case (.b(let req1), .b(let req2)):
                try assertEqualOldToNew(req1, req2)
            default:
                XCTFail("One request was a reference and the other was not. \(newRequest)  /  \(oldRequest)")
            }
        } else {
            XCTAssertNil(oldOp.requestBody)
        }
        assertEqualOldToNew(newOp.responses, oldOp.responses)
        try assertEqualOldToNew(newOp.callbacks, oldOp.callbacks)
        XCTAssertEqual(newOp.deprecated, oldOp.deprecated)
        if let newSecurity = newOp.security {
            let oldSecurity = try XCTUnwrap(oldOp.security)

            for (newSecurityReq, oldSecurityReq) in zip(newSecurity, oldSecurity) {
                try assertEqualOldToNew(newSecurityReq, oldSecurityReq)
            }
        } else {
            XCTAssertNil(oldOp.security)
        }
        if let newServers = newOp.servers {
            let oldServers = try XCTUnwrap(oldOp.servers)

            for (newServer, oldServer) in zip(newServers, oldServers) {
                assertEqualOldToNew(newServer, oldServer)
            }
        } else {
            XCTAssertNil(oldOp.servers)
        }
        XCTAssertEqual(newOp.vendorExtensions, oldOp.vendorExtensions)
    } else {
        XCTAssertNil(oldOperation)
    }
}

fileprivate func assertEqualOldToNew(_ newSecurityReq: OpenAPIKit.OpenAPI.SecurityRequirement, _ oldSecurityReq: OpenAPIKit30.OpenAPI.SecurityRequirement) throws {
    for (ref, strs) in newSecurityReq {
        switch ref {
        case .internal(let internalRef):
            let maybeOldRefInternal = OpenAPIKit30.JSONReference<OpenAPIKit30.OpenAPI.SecurityScheme>.InternalReference(rawValue: internalRef.rawValue)
            let oldRefInternal = try XCTUnwrap(maybeOldRefInternal)
            let oldRef = OpenAPIKit30.JSONReference<OpenAPIKit30.OpenAPI.SecurityScheme>.internal(oldRefInternal)
            let oldStrs = oldSecurityReq[oldRef]
            XCTAssertEqual(strs, oldStrs)
        case .external(let external):
            let oldStrs = oldSecurityReq[.external(external)]
            XCTAssertEqual(strs, oldStrs)
        }
    }
}

fileprivate func assertEqualOldToNew(_ newRequest: OpenAPIKit.OpenAPI.Request, _ oldRequest: OpenAPIKit30.OpenAPI.Request) throws {
    XCTAssertEqual(newRequest.description, oldRequest.description)
    try assertEqualOldToNew(newRequest.content, oldRequest.content)
    XCTAssertEqual(newRequest.required, oldRequest.required)
    XCTAssertEqual(newRequest.vendorExtensions, oldRequest.vendorExtensions)
}

fileprivate func assertEqualOldToNew(_ newContentMap: OpenAPIKit.OpenAPI.Content.Map, _ oldContentMap: OpenAPIKit30.OpenAPI.Content.Map) throws {
    for ((newCt, newContent), (oldCt, oldContent)) in zip(newContentMap, oldContentMap) {
        XCTAssertEqual(newCt, oldCt)
        switch (newContent.schema, oldContent.schema) {
        case (.a(let ref1), .a(let ref2)):
            XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
        case (.b(let schema1), .b(let schema2)):
            assertEqualOldToNew(schema1, schema2)
        default:
            XCTFail("Found one reference and one schema. \(String(describing: newContent.schema))   /   \(String(describing: oldContent.schema))")
        }
        XCTAssertEqual(newContent.example, oldContent.example)
        if let newContentExamplesRef = newContent.examples {
            let oldContentExamplesRef = try XCTUnwrap(oldContent.examples)
            for ((newKey, newExampleRef), (oldKey, oldExampleRef)) in zip(newContentExamplesRef, oldContentExamplesRef) {
                XCTAssertEqual(newKey, oldKey)
                switch (newExampleRef, oldExampleRef) {
                case (.a(let ref1), .a(let ref2)):
                    XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
                case (.b(let example1), .b(let example2)):
                    assertEqualOldToNew(example1, example2)
                default:
                    XCTFail("Found one reference and one example. \(newExampleRef)   /   \(oldExampleRef)")
                }
            }
        } else {
            XCTAssertNil(oldContent.examples)
        }
        if let newEncodingRef = newContent.encoding {
            let oldEncodingRef = try XCTUnwrap(oldContent.encoding)
            for ((newKey, newEncoding), (oldKey, oldEncoding)) in zip(newEncodingRef, oldEncodingRef) {
                XCTAssertEqual(newKey, oldKey)
                try assertEqualOldToNew(newEncoding, oldEncoding)
            }
        } else {
            XCTAssertNil(oldContent.encoding)
        }
        XCTAssertEqual(newContent.vendorExtensions, oldContent.vendorExtensions)
    }
}

fileprivate func assertEqualOldToNew(_ newSchema: OpenAPIKit.JSONSchema, _ oldSchema: OpenAPIKit30.JSONSchema) {
        // TODO
}

fileprivate func assertEqualOldToNew(_ newExample: OpenAPIKit.OpenAPI.Example, _ oldExample: OpenAPIKit30.OpenAPI.Example) {
    XCTAssertEqual(newExample.summary, oldExample.summary)
    XCTAssertEqual(newExample.description, oldExample.description)
    XCTAssertEqual(newExample.value, oldExample.value)
    XCTAssertEqual(newExample.vendorExtensions, oldExample.vendorExtensions)
}

fileprivate func assertEqualOldToNew(_ newEncoding: OpenAPIKit.OpenAPI.Content.Encoding, _ oldEncoding: OpenAPIKit30.OpenAPI.Content.Encoding) throws {
    XCTAssertEqual(newEncoding.contentType, oldEncoding.contentType)
    if let newEncodingHeaders = newEncoding.headers {
        let oldEncodingHeaders = try XCTUnwrap(oldEncoding.headers)
        for ((newKey, newHeader), (oldKey, oldHeader)) in zip(newEncodingHeaders, oldEncodingHeaders) {
            XCTAssertEqual(newKey, oldKey)
            switch (newHeader, oldHeader) {
            case (.a(let ref1), .a(let ref2)):
                XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
            case (.b(let header1), .b(let header2)):
                try assertEqualOldToNew(header1, header2)
            default:
                XCTFail("Found one reference and one header. \(newHeader)  /  \(oldHeader)")
            }
        }
    } else {
        XCTAssertNil(oldEncoding.headers)
    }
    XCTAssertEqual(newEncoding.style, oldEncoding.style)
    XCTAssertEqual(newEncoding.explode, oldEncoding.explode)
    XCTAssertEqual(newEncoding.allowReserved, oldEncoding.allowReserved)
}

fileprivate func assertEqualOldToNew(_ newHeader: OpenAPIKit.OpenAPI.Header, _ oldHeader: OpenAPIKit30.OpenAPI.Header) throws {
    XCTAssertEqual(newHeader.description, oldHeader.description)
    XCTAssertEqual(newHeader.required, oldHeader.required)
    XCTAssertEqual(newHeader.deprecated, oldHeader.deprecated)
    switch (newHeader.schemaOrContent, oldHeader.schemaOrContent) {
    case (.a(let schema1), .a(let schema2)):
        try assertEqualOldToNew(schema1, schema2)
    case (.b(let content1), .b(let content2)):
        try assertEqualOldToNew(content1, content2)
    default:
        XCTFail("Found one schema and one content map. \(newHeader.schemaOrContent)  /  \(oldHeader.schemaOrContent)")
    }
    XCTAssertEqual(newHeader.vendorExtensions, oldHeader.vendorExtensions)
}

fileprivate func assertEqualOldToNew(_ newSchemaContext: OpenAPIKit.OpenAPI.Parameter.SchemaContext, _ oldSchemaContext: OpenAPIKit30.OpenAPI.Parameter.SchemaContext) throws {
    XCTAssertEqual(newSchemaContext.style, oldSchemaContext.style)
    XCTAssertEqual(newSchemaContext.explode, oldSchemaContext.explode)
    XCTAssertEqual(newSchemaContext.allowReserved, oldSchemaContext.allowReserved)
    switch (newSchemaContext.schema, oldSchemaContext.schema) {
    case (.a(let ref1), .a(let ref2)):
        XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
    case (.b(let schema1), .b(let schema2)):
        assertEqualOldToNew(schema1, schema2)
    default:
        XCTFail("Found one reference and one schema. \(newSchemaContext.schema)  /  \(oldSchemaContext.schema)")
    }
    XCTAssertEqual(newSchemaContext.example, oldSchemaContext.example)
    if let newExamplesRef = newSchemaContext.examples {
        let oldExamplesRef = try XCTUnwrap(oldSchemaContext.examples)
        for ((newKey, newExampleRef), (oldKey, oldExampleRef)) in zip(newExamplesRef, oldExamplesRef) {
            XCTAssertEqual(newKey, oldKey)
            switch (newExampleRef, oldExampleRef) {
            case (.a(let ref1), .a(let ref2)):
                XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
            case (.b(let example1), .b(let example2)):
                assertEqualOldToNew(example1, example2)
            default:
                XCTFail("Found one reference and one example. \(newExampleRef)   /   \(oldExampleRef)")
            }
        }
    } else {
        XCTAssertNil(oldSchemaContext.examples)
    }
}

fileprivate func assertEqualOldToNew(_ newResponseMap: OpenAPIKit.OpenAPI.Response.Map, _ oldResponseMap: OpenAPIKit30.OpenAPI.Response.Map) {
        // TODO
}

fileprivate func assertEqualOldToNew(_ newCallbacksMap: OpenAPIKit.OpenAPI.CallbacksMap, _ oldCallbacksMap: OpenAPIKit30.OpenAPI.CallbacksMap) throws {
    XCTAssertEqual(newCallbacksMap.count, oldCallbacksMap.count)
    for (key, ref) in newCallbacksMap {
        let oldRef = try XCTUnwrap(oldCallbacksMap[key])
        switch (ref, oldRef) {
        case (.a(let ref1), .a(let ref2)):
            XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
        case (.b(let callback1), .b(let callback2)):
            for (url, pathItemRef) in callback1 {
                let pathItem2 = try XCTUnwrap(callback2[url])
                switch pathItemRef {
                case .a(_):
                    XCTFail("Found a reference in OpenAPI 3.1 document where OpenAPI 3.0 does not support references!")
                case .b(let pathItem):
                    try assertEqualOldToNew(pathItem, pathItem2)
                }
            }
        default:
            XCTFail("Found reference to a callbacks object in one document and actual callbacks object in the other. \(ref)    /    \(oldRef)")
        }
    }
}

fileprivate func assertEqualOldToNew(_ newExternalDocs: OpenAPIKit.OpenAPI.ExternalDocumentation?, _ oldExternalDocs: OpenAPIKit30.OpenAPI.ExternalDocumentation?) throws {
    if let newDocs = newExternalDocs {
        let oldDocs = try XCTUnwrap(oldExternalDocs)
        XCTAssertEqual(newDocs.description, oldDocs.description)
        XCTAssertEqual(newDocs.url, oldDocs.url)
        XCTAssertEqual(newDocs.vendorExtensions, oldDocs.vendorExtensions)
    } else {
        XCTAssertNil(oldExternalDocs)
    }
}

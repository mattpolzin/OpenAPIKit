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
        try assertEqualOldToNew(newPathItem, oldPathItem)
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

fileprivate func assertEqualOldToNew(_ newPathItem: OpenAPIKit.OpenAPI.PathItem, _ oldPathItem: OpenAPIKit30.OpenAPI.PathItem) throws {
    XCTAssertEqual(newPathItem.summary, oldPathItem.summary)
    XCTAssertEqual(newPathItem.description, oldPathItem.description)
    if let newServers = newPathItem.servers {
        let oldServers = try XCTUnwrap(oldPathItem.servers)
        for (newServer, oldServer) in zip(newServers, oldServers) {
                assertEqualOldToNew(newServer, oldServer)
        }
    }
    for (newParameter, oldParameter) in zip(newPathItem.parameters, oldPathItem.parameters) {
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
        // TODO
    } else {
        XCTAssertNil(oldOperation)
    }
}

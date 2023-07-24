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

        try assertEqualNewToOld(newDoc, oldDoc)
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

        try assertEqualNewToOld(newDoc, oldDoc)
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

        try assertEqualNewToOld(newDoc, oldDoc)
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

        try assertEqualNewToOld(newDoc, oldDoc)
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
            callbacks: [
                "callback": .b(callbacks),
                "other_callback": .a(.component(named: "other_callback"))],
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

        try assertEqualNewToOld(newDoc, oldDoc)
    }

    func testJSONSchemas() throws {
        // TODO: write test
    }

    func testComponents() throws {
        let param: OpenAPIKit30.OpenAPI.Parameter = .init(name: "test", context: .query, schema: .string)
        let param2: OpenAPIKit30.OpenAPI.Parameter = .init(name: "test2", context: .cookie, content: [.anyFont: .init(schema: .reference(.external(URL(string: "https://website.com")!)), examples: ["good_example": .example(.init(value: .b("my-font")))])])
        let param3: OpenAPIKit30.OpenAPI.Parameter = .init(name: "test3", context: .header, schemaReference: .component(named: "test3_param"))
        let param4: OpenAPIKit30.OpenAPI.Parameter = .init(name: "test4", context: .path, schemaOrContent: .schema(.header(.boolean)))

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

        let components = OpenAPIKit30.OpenAPI.Components(
            schemas: [
                "schema1": .string
            ],
            responses: [
                "response1": response
            ],
            parameters: [
                "param1": param,
                "param2": param2,
                "param3": param3,
                "param4": param4
            ],
            examples: [
                "example1": .init(
                    summary: "summary",
                    description: "description",
                    value: .b("hello"),
                    vendorExtensions: ["x-example-ext": 123]
                ),
                "example2": .init(value: .a(URL(string: "https://website.com")!))
            ],
            requestBodies: [
                "request1": request
            ],
            headers: [
                "header1": .init(schema: .string)
            ],
            securitySchemes: [
                "securityScheme1": .apiKey(name: "hi", location: .header),
                "securityScheme2": .apiKey(name: "hi", location: .query),
                "securityScheme3": .apiKey(name: "hi", location: .cookie),
                "securityScheme4": .http(scheme: "hi"),
                "securityScheme5": .http(scheme: "hi", bearerFormat: "hello", description: "description"),
                "securityScheme6": .oauth2(flows: .init()),
                "securityScheme7": .oauth2(flows: .init(), description: "hello"),
                "securityScheme8": .openIdConnect(url: URL(string: "https://website.com")!),
                "securityScheme9": .openIdConnect(url: URL(string: "https://website.com")!, description: "hello")
            ],
            links: [
                "link1": .init(operation: .b("hello")),
                "link2": .init(operation: .a(URL(string: "https://website.com")!)),
                "link3": .init(operationId: "op id"),
                "link4": .init(operationRef: URL(string: "https://website.com")!),
                "link5": .init(operationId: "op id2",parameters: [
                    "link_param1": .a(.url),
                    "link_param2": .a(.method),
                    "link_param3": .a(.request(.header(name: "param3"))),
                    "link_param4": .a(.response(.query(name: "param4"))),
                    "link_param5": .a(.response(.path(name: "param5"))),
                    "link_param6": .a(.response(.body(.component(name: "link_param6"))))
                ])
            ],
            callbacks: [
                "callbacks1": callbacks
            ]
        )

        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: components
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc, oldDoc)
    }

    func testSecurity() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            security: []
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc, oldDoc)

        let oldDoc2 = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .init(
                securitySchemes: ["security": .init(type: .apiKey(name: "key", location: .header))]
            ),
            security: [
                [.component( named: "security"):[]]
            ]
        )

        let newDoc2 = oldDoc2.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc2, oldDoc2)
    }

    func testTags() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: nil
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc, oldDoc)

        let oldDoc2 = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: []
        )

        let newDoc2 = oldDoc2.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc2, oldDoc2)

        let oldDoc3 = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: [
                .init(name: "tag name", description: "tag description", externalDocs: .init(url: URL(string: "https://website.com")!), vendorExtensions: ["x-tag-ext": "tag extension"]),
                "this is another tag"
            ]
        )

        let newDoc3 = oldDoc3.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc3, oldDoc3)
    }

    func testExternalDocs() throws {
        let externalDocs = OpenAPIKit30.OpenAPI.ExternalDocumentation(
            description: "hello",
            url: URL(string: "https://website.com")!,
            vendorExtensions: ["x-hi": 3]
        )

        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            externalDocs: externalDocs
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc, oldDoc)
    }

    func testVendorExtensions() throws {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            vendorExtensions: ["x-doc-extension" : "noice"]
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        try assertEqualNewToOld(newDoc, oldDoc)
    }

    // TODO: more tests
}

fileprivate func assertEqualNewToOld(_ newDoc: OpenAPIKit.OpenAPI.Document, _ oldDoc: OpenAPIKit30.OpenAPI.Document) throws {
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
        try assertEqualNewToOld(newServer, oldServer)
    }

    // PATHS
    XCTAssertEqual(newDoc.paths.count, oldDoc.paths.count)
    for (path, newPathItem) in newDoc.paths {
        let oldPathItem = try XCTUnwrap(oldDoc.paths[path])
        try assertEqualNewToOld(newPathItem.pathItemValue, oldPathItem) // TODO: switch back to not only testing the non-reference case once OpenAPIKit30 has gained the ability to reference path items as well.
    }

    // COMPONENTS
    try assertEqualNewToOld(newDoc.components, oldDoc.components)

    // SECURITY
    XCTAssertEqual(newDoc.security.count, oldDoc.security.count)
    for (newSec, oldSec) in zip(newDoc.security, oldDoc.security) {
        try assertEqualNewToOld(newSec, oldSec)
    }

    // TAGS
    XCTAssertEqual(newDoc.tags?.count, oldDoc.tags?.count)
    if let newTags = newDoc.tags, let oldTags = oldDoc.tags {
        for (newTag, oldTag) in zip(newTags, oldTags) {
            try assertEqualNewToOld(newTag, oldTag)
        }
    }

    // EXTERNAL DOCS
    try assertEqualNewToOld(newDoc.externalDocs, oldDoc.externalDocs)

    // VENDOR EXTENSIONS
    XCTAssertEqual(newDoc.vendorExtensions, oldDoc.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newTag: OpenAPIKit.OpenAPI.Tag, _ oldTag: OpenAPIKit30.OpenAPI.Tag) throws {
    XCTAssertEqual(newTag.name, oldTag.name)
    XCTAssertEqual(newTag.description, oldTag.description)
    try assertEqualNewToOld(newTag.externalDocs, oldTag.externalDocs)
    XCTAssertEqual(newTag.vendorExtensions, oldTag.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newServer: OpenAPIKit.OpenAPI.Server?, _ oldServer: OpenAPIKit30.OpenAPI.Server?) throws {
    guard let newServer = newServer else {
        XCTAssertNil(oldServer)
        return
    }
    let oldServer = try XCTUnwrap(oldServer)
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

fileprivate func assertEqualNewToOld(_ newParamArray: OpenAPIKit.OpenAPI.Parameter.Array, _ oldParamArray: OpenAPIKit30.OpenAPI.Parameter.Array) {
    for (newParameter, oldParameter) in zip(newParamArray, oldParamArray) {
        switch (newParameter, oldParameter) {
        case (.a(let ref), .a(let ref2)):
            XCTAssertNil(ref.summary)
            XCTAssertNil(ref.description)
            XCTAssertEqual(ref.jsonReference.absoluteString, ref2.absoluteString)
        case (.b(let param), .b(let param2)):
            assertEqualNewToOld(param, param2)
        default:
            XCTFail("Parameters are not equal because one is a reference and the other is not: \(newParameter)  / \(oldParameter)")
        }
    }
}

fileprivate func assertEqualNewToOld(_ newPathItem: OpenAPIKit.OpenAPI.PathItem?, _ oldPathItem: OpenAPIKit30.OpenAPI.PathItem?) throws {
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
            try assertEqualNewToOld(newServer, oldServer)
        }
    }
    assertEqualNewToOld(newPathItem.parameters, oldPathItem.parameters)
    try assertEqualNewToOld(newPathItem.get, oldPathItem.get)
    try assertEqualNewToOld(newPathItem.put, oldPathItem.put)
    try assertEqualNewToOld(newPathItem.post, oldPathItem.post)
    try assertEqualNewToOld(newPathItem.delete, oldPathItem.delete)
    try assertEqualNewToOld(newPathItem.options, oldPathItem.options)
    try assertEqualNewToOld(newPathItem.head, oldPathItem.head)
    try assertEqualNewToOld(newPathItem.patch, oldPathItem.patch)
    try assertEqualNewToOld(newPathItem.trace, oldPathItem.trace)

    XCTAssertEqual(newPathItem.vendorExtensions, oldPathItem.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newParam: OpenAPIKit.OpenAPI.Parameter, _ oldParam: OpenAPIKit30.OpenAPI.Parameter) {
    XCTAssertEqual(newParam.name, oldParam.name)
    assertEqualNewToOld(newParam.context, oldParam.context)
    XCTAssertEqual(newParam.description, oldParam.description)
    XCTAssertEqual(newParam.deprecated, oldParam.deprecated)
    XCTAssertEqual(newParam.vendorExtensions, oldParam.vendorExtensions)
    XCTAssertEqual(newParam.required, oldParam.required)
}

fileprivate func assertEqualNewToOld(_ newParamContext: OpenAPIKit.OpenAPI.Parameter.Context, _ oldParamContext: OpenAPIKit30.OpenAPI.Parameter.Context) {
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

fileprivate func assertEqualNewToOld(_ newOperation: OpenAPIKit.OpenAPI.Operation?, _ oldOperation: OpenAPIKit30.OpenAPI.Operation?) throws {
    if let newOp = newOperation {
        let oldOp = try XCTUnwrap(oldOperation)

        XCTAssertEqual(newOp.tags, oldOp.tags)
        XCTAssertEqual(newOp.summary, oldOp.summary)
        XCTAssertEqual(newOp.description, oldOp.description)
        try assertEqualNewToOld(newOp.externalDocs, oldOp.externalDocs)
        XCTAssertEqual(newOp.operationId, oldOp.operationId)
        assertEqualNewToOld(newOp.parameters, oldOp.parameters)
        if let newRequest = newOp.requestBody {
            let oldRequest = try XCTUnwrap(oldOp.requestBody)
            switch (newRequest, oldRequest) {
            case (.a(let ref1), .a(let ref2)):
                XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
            case (.b(let req1), .b(let req2)):
                try assertEqualNewToOld(req1, req2)
            default:
                XCTFail("One request was a reference and the other was not. \(newRequest)  /  \(oldRequest)")
            }
        } else {
            XCTAssertNil(oldOp.requestBody)
        }
        try assertEqualNewToOld(newOp.responses, oldOp.responses)
        try assertEqualNewToOld(newOp.callbacks, oldOp.callbacks)
        XCTAssertEqual(newOp.deprecated, oldOp.deprecated)
        if let newSecurity = newOp.security {
            let oldSecurity = try XCTUnwrap(oldOp.security)

            for (newSecurityReq, oldSecurityReq) in zip(newSecurity, oldSecurity) {
                try assertEqualNewToOld(newSecurityReq, oldSecurityReq)
            }
        } else {
            XCTAssertNil(oldOp.security)
        }
        if let newServers = newOp.servers {
            let oldServers = try XCTUnwrap(oldOp.servers)

            for (newServer, oldServer) in zip(newServers, oldServers) {
                try assertEqualNewToOld(newServer, oldServer)
            }
        } else {
            XCTAssertNil(oldOp.servers)
        }
        XCTAssertEqual(newOp.vendorExtensions, oldOp.vendorExtensions)
    } else {
        XCTAssertNil(oldOperation)
    }
}

fileprivate func assertEqualNewToOld(_ newSecurityReq: OpenAPIKit.OpenAPI.SecurityRequirement, _ oldSecurityReq: OpenAPIKit30.OpenAPI.SecurityRequirement) throws {
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

fileprivate func assertEqualNewToOld(_ newRequest: OpenAPIKit.OpenAPI.Request, _ oldRequest: OpenAPIKit30.OpenAPI.Request) throws {
    XCTAssertEqual(newRequest.description, oldRequest.description)
    try assertEqualNewToOld(newRequest.content, oldRequest.content)
    XCTAssertEqual(newRequest.required, oldRequest.required)
    XCTAssertEqual(newRequest.vendorExtensions, oldRequest.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newContentMap: OpenAPIKit.OpenAPI.Content.Map, _ oldContentMap: OpenAPIKit30.OpenAPI.Content.Map) throws {
    for ((newCt, newContent), (oldCt, oldContent)) in zip(newContentMap, oldContentMap) {
        XCTAssertEqual(newCt, oldCt)
        switch (newContent.schema, oldContent.schema) {
        case (.a(let ref1), .a(let ref2)):
            XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
        case (.b(let schema1), .b(let schema2)):
            assertEqualNewToOld(schema1, schema2)
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
                    assertEqualNewToOld(example1, example2)
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
                try assertEqualNewToOld(newEncoding, oldEncoding)
            }
        } else {
            XCTAssertNil(oldContent.encoding)
        }
        XCTAssertEqual(newContent.vendorExtensions, oldContent.vendorExtensions)
    }
}

fileprivate func assertEqualNewToOld(_ newSchema: OpenAPIKit.JSONSchema, _ oldSchema: OpenAPIKit30.JSONSchema) {
        // TODO
}

fileprivate func assertEqualNewToOld(_ newExample: OpenAPIKit.OpenAPI.Example, _ oldExample: OpenAPIKit30.OpenAPI.Example) {
    XCTAssertEqual(newExample.summary, oldExample.summary)
    XCTAssertEqual(newExample.description, oldExample.description)
    XCTAssertEqual(newExample.value, oldExample.value)
    XCTAssertEqual(newExample.vendorExtensions, oldExample.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newEncoding: OpenAPIKit.OpenAPI.Content.Encoding, _ oldEncoding: OpenAPIKit30.OpenAPI.Content.Encoding) throws {
    XCTAssertEqual(newEncoding.contentType, oldEncoding.contentType)
    if let newEncodingHeaders = newEncoding.headers {
        let oldEncodingHeaders = try XCTUnwrap(oldEncoding.headers)
        for ((newKey, newHeader), (oldKey, oldHeader)) in zip(newEncodingHeaders, oldEncodingHeaders) {
            XCTAssertEqual(newKey, oldKey)
            switch (newHeader, oldHeader) {
            case (.a(let ref1), .a(let ref2)):
                XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
            case (.b(let header1), .b(let header2)):
                try assertEqualNewToOld(header1, header2)
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

fileprivate func assertEqualNewToOld(_ newHeader: OpenAPIKit.OpenAPI.Header, _ oldHeader: OpenAPIKit30.OpenAPI.Header) throws {
    XCTAssertEqual(newHeader.description, oldHeader.description)
    XCTAssertEqual(newHeader.required, oldHeader.required)
    XCTAssertEqual(newHeader.deprecated, oldHeader.deprecated)
    switch (newHeader.schemaOrContent, oldHeader.schemaOrContent) {
    case (.a(let schema1), .a(let schema2)):
        try assertEqualNewToOld(schema1, schema2)
    case (.b(let content1), .b(let content2)):
        try assertEqualNewToOld(content1, content2)
    default:
        XCTFail("Found one schema and one content map. \(newHeader.schemaOrContent)  /  \(oldHeader.schemaOrContent)")
    }
    XCTAssertEqual(newHeader.vendorExtensions, oldHeader.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newSchemaContext: OpenAPIKit.OpenAPI.Parameter.SchemaContext, _ oldSchemaContext: OpenAPIKit30.OpenAPI.Parameter.SchemaContext) throws {
    XCTAssertEqual(newSchemaContext.style, oldSchemaContext.style)
    XCTAssertEqual(newSchemaContext.explode, oldSchemaContext.explode)
    XCTAssertEqual(newSchemaContext.allowReserved, oldSchemaContext.allowReserved)
    switch (newSchemaContext.schema, oldSchemaContext.schema) {
    case (.a(let ref1), .a(let ref2)):
        XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
    case (.b(let schema1), .b(let schema2)):
        assertEqualNewToOld(schema1, schema2)
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
                assertEqualNewToOld(example1, example2)
            default:
                XCTFail("Found one reference and one example. \(newExampleRef)   /   \(oldExampleRef)")
            }
        }
    } else {
        XCTAssertNil(oldSchemaContext.examples)
    }
}

fileprivate func assertEqualNewToOld(_ newResponseMap: OpenAPIKit.OpenAPI.Response.Map, _ oldResponseMap: OpenAPIKit30.OpenAPI.Response.Map) throws {
    XCTAssertEqual(newResponseMap.count, oldResponseMap.count)
    for (key, ref) in newResponseMap {
        let oldRef = try XCTUnwrap(oldResponseMap[key])
        switch (ref, oldRef) {
        case (.a(let ref1), .a(let ref2)):
            XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
        case (.b(let resp1), .b(let resp2)):
            try assertEqualNewToOld(resp1, resp2)
        default:
            XCTFail("Found reference to a response in one document and actual response in the other. \(ref)    /    \(oldRef)")
        }
    }
}

fileprivate func assertEqualNewToOld(_ newResponse: OpenAPIKit.OpenAPI.Response, _ oldResponse: OpenAPIKit30.OpenAPI.Response) throws {
    XCTAssertEqual(newResponse.description, oldResponse.description)
    try assertEqualNewToOld(newResponse.headers, oldResponse.headers)
    try assertEqualNewToOld(newResponse.content, oldResponse.content)
    try assertEqualNewToOld(newResponse.links, oldResponse.links)
    XCTAssertEqual(newResponse.vendorExtensions, oldResponse.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newHeadersMap: OpenAPIKit.OpenAPI.Header.Map?, _ oldHeadersMap: OpenAPIKit30.OpenAPI.Header.Map?) throws {
    guard let newHeadersMap = newHeadersMap else {
        XCTAssertNil(oldHeadersMap)
        return
    }
    let oldHeadersMap = try XCTUnwrap(oldHeadersMap)

    XCTAssertEqual(newHeadersMap.count, oldHeadersMap.count)
    for (key, ref) in newHeadersMap {
        let oldRef = try XCTUnwrap(oldHeadersMap[key])
        switch (ref, oldRef) {
        case (.a(let ref1), .a(let ref2)):
            XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
        case (.b(let header1), .b(let header2)):
            try assertEqualNewToOld(header1, header2)
        default:
            XCTFail("Found reference to a callbacks object in one document and actual callbacks object in the other. \(ref)    /    \(oldRef)")
        }
    }
}

fileprivate func assertEqualNewToOld(_ newLinksMap: OpenAPIKit.OpenAPI.Link.Map, _ oldLinksMap: OpenAPIKit30.OpenAPI.Link.Map) throws {
    XCTAssertEqual(newLinksMap.count, oldLinksMap.count)
    for (key, ref) in newLinksMap {
        let oldRef = try XCTUnwrap(oldLinksMap[key])
        switch (ref, oldRef) {
        case (.a(let ref1), .a(let ref2)):
            XCTAssertEqual(ref1.absoluteString, ref2.absoluteString)
        case (.b(let link1), .b(let link2)):
            try assertEqualNewToOld(link1, link2)
        default:
            XCTFail("Found reference to a callbacks object in one document and actual callbacks object in the other. \(ref)    /    \(oldRef)")
        }
    }
}

fileprivate func assertEqualNewToOld(_ newLink: OpenAPIKit.OpenAPI.Link, _ oldLink: OpenAPIKit30.OpenAPI.Link) throws {
    XCTAssertEqual(newLink.operation, oldLink.operation)
    XCTAssertEqual(newLink.parameters.count, oldLink.parameters.count)
    for (key, newExp) in newLink.parameters {
        let oldExp = try XCTUnwrap(oldLink.parameters[key])
        switch (newExp, oldExp) {
        case (.b(let anyCodable1), .b(let anyCodable2)):
            XCTAssertEqual(anyCodable1, anyCodable2)
        case (.a(let exp1), .a(let exp2)):
            assertEqualNewToOld(exp1, exp2)
        default:
            XCTFail("Found a runtime expression in one parameter and an AnyCodable in the other. \(newExp)    /    \(oldExp)")
        }
    }
    switch (newLink.requestBody, oldLink.requestBody) {
    case (nil, nil):
        break
    case (nil, let other):
        XCTFail("Found nil in the new link's request body and a populated request body in the old link. nil    /    \(String(describing: other))")
    case (let other, nil):
        XCTFail("Found a request body in the new link and nil in the old link's request body. \(String(describing: other))    /    nil")
    case (.b(let anyCodable1), .b(let anyCodable2)):
        XCTAssertEqual(anyCodable1, anyCodable2)
    case (.a(let exp1), .a(let exp2)):
        assertEqualNewToOld(exp1, exp2)
    default:
        XCTFail("Found a request body in one link and an AnyCodable in the other. \(String(describing: newLink.requestBody))    /    \(String(describing: oldLink.requestBody))")
    }
    XCTAssertEqual(newLink.description, oldLink.description)
    try assertEqualNewToOld(newLink.server, oldLink.server)
    XCTAssertEqual(newLink.vendorExtensions, oldLink.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newRuntimeExpression: OpenAPIKit.OpenAPI.RuntimeExpression, _ oldRuntimeExpression: OpenAPIKit30.OpenAPI.RuntimeExpression) {
    switch (newRuntimeExpression, oldRuntimeExpression) {
    case (.url, .url):
        break
    case (.method, .method):
        break
    case (.statusCode, .statusCode):
        break
    case (.request(let source1), .request(let source2)):
        assertEqualNewToOld(source1, source2)
    case (.response(let source1), .response(let source2)):
        assertEqualNewToOld(source1, source2)
    default:
        XCTFail("Runtime expressions are of different cases: \(newRuntimeExpression)    /    \(oldRuntimeExpression)")
    }
}

fileprivate func assertEqualNewToOld(_ newRuntimeExpressionSource: OpenAPIKit.OpenAPI.RuntimeExpression.Source, _ oldRuntimeExpressionSource: OpenAPIKit30.OpenAPI.RuntimeExpression.Source) {
    switch (newRuntimeExpressionSource, oldRuntimeExpressionSource) {
    case (.header(let s1), .header(let s2)):
        XCTAssertEqual(s1, s2)
    case (.query(let s1), .query(let s2)):
        XCTAssertEqual(s1, s2)
    case (.path(let s1), .path(let s2)):
        XCTAssertEqual(s1, s2)
    case (.body(let ref1), .body(let ref2)):
        XCTAssertEqual(ref1?.rawValue, ref2?.rawValue)
    default:
        XCTFail("Runtime expression sources were of different cases: \(newRuntimeExpressionSource)    /    \(oldRuntimeExpressionSource)")
    }
}

fileprivate func assertEqualNewToOld(_ newCallbacksMap: OpenAPIKit.OpenAPI.CallbacksMap, _ oldCallbacksMap: OpenAPIKit30.OpenAPI.CallbacksMap) throws {
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
                    try assertEqualNewToOld(pathItem, pathItem2)
                }
            }
        default:
            XCTFail("Found reference to a callbacks object in one document and actual callbacks object in the other. \(ref)    /    \(oldRef)")
        }
    }
}

fileprivate func assertEqualNewToOld(_ newExternalDocs: OpenAPIKit.OpenAPI.ExternalDocumentation?, _ oldExternalDocs: OpenAPIKit30.OpenAPI.ExternalDocumentation?) throws {
    if let newDocs = newExternalDocs {
        let oldDocs = try XCTUnwrap(oldExternalDocs)
        XCTAssertEqual(newDocs.description, oldDocs.description)
        XCTAssertEqual(newDocs.url, oldDocs.url)
        XCTAssertEqual(newDocs.vendorExtensions, oldDocs.vendorExtensions)
    } else {
        XCTAssertNil(oldExternalDocs)
    }
}

fileprivate func assertEqualNewToOld(_ newComponents: OpenAPIKit.OpenAPI.Components, _ oldComponents: OpenAPIKit30.OpenAPI.Components) throws {
    XCTAssertEqual(newComponents.schemas.count, oldComponents.schemas.count)
    XCTAssertEqual(newComponents.responses.count, oldComponents.responses.count)
    XCTAssertEqual(newComponents.parameters.count, oldComponents.parameters.count)
    XCTAssertEqual(newComponents.examples.count, oldComponents.examples.count)
    XCTAssertEqual(newComponents.requestBodies.count, oldComponents.requestBodies.count)
    XCTAssertEqual(newComponents.headers.count, oldComponents.headers.count)
    XCTAssertEqual(newComponents.securitySchemes.count, oldComponents.securitySchemes.count)
    XCTAssertEqual(newComponents.links.count, oldComponents.links.count)
    XCTAssertEqual(newComponents.callbacks.count, oldComponents.callbacks.count)
    XCTAssertEqual(newComponents.pathItems.count, 0)

    for (key, newSchema) in newComponents.schemas {
        let oldSchema = try XCTUnwrap(oldComponents.schemas[key])
        assertEqualNewToOld(newSchema, oldSchema)
    }
    for (key, newResponse) in newComponents.responses {
        let oldResponse = try XCTUnwrap(oldComponents.responses[key])
        try assertEqualNewToOld(newResponse, oldResponse)
    }
    for (key, newParameter) in newComponents.parameters {
        let oldParameter = try XCTUnwrap(oldComponents.parameters[key])
        assertEqualNewToOld(newParameter, oldParameter)
    }
    for (key, newExample) in newComponents.examples {
        let oldExample = try XCTUnwrap(oldComponents.examples[key])
        assertEqualNewToOld(newExample, oldExample)
    }
    for (key, newRequest) in newComponents.requestBodies {
        let oldRequest = try XCTUnwrap(oldComponents.requestBodies[key])
        try assertEqualNewToOld(newRequest, oldRequest)
    }
    for (key, newHeader) in newComponents.headers {
        let oldHeader = try XCTUnwrap(oldComponents.headers[key])
        try assertEqualNewToOld(newHeader, oldHeader)
    }
    for (key, newSecurity) in newComponents.securitySchemes {
        let oldSecurity = try XCTUnwrap(oldComponents.securitySchemes[key])
        try assertEqualNewToOld(newSecurity, oldSecurity)
    }
    for (key, newLink) in newComponents.links {
        let oldLink = try XCTUnwrap(oldComponents.links[key])
        try assertEqualNewToOld(newLink, oldLink)
    }
    for (key, newCallbacks) in newComponents.callbacks {
        let oldCallbacks = try XCTUnwrap(oldComponents.callbacks[key])
        for (key, newCallback) in newCallbacks {
            let oldPathItem = try XCTUnwrap(oldCallbacks[key])
            switch (newCallback) {
            case (.a(let ref)):
                XCTFail("Found a path item reference even though OpenAPI 3.0.x did not support path item references in Callbacks. \(ref)")
                return
            case (.b(let newPathItem)):
                try assertEqualNewToOld(newPathItem, oldPathItem)
            }
        }
    }
    XCTAssertEqual(newComponents.vendorExtensions, oldComponents.vendorExtensions)
}

fileprivate func assertEqualNewToOld(_ newScheme: OpenAPIKit.OpenAPI.SecurityScheme, _ oldScheme: OpenAPIKit30.OpenAPI.SecurityScheme) throws {
    XCTAssertEqual(newScheme.description, oldScheme.description)
    XCTAssertEqual(newScheme.vendorExtensions, oldScheme.vendorExtensions)

    switch (newScheme.type, oldScheme.type) {
    case (.apiKey(let name, let location), .apiKey(let name2, let location2)):
        XCTAssertEqual(name, name2)
        XCTAssertEqual(location, location2)
    case (.http(let scheme, let format), .http(let scheme2, let format2)):
        XCTAssertEqual(scheme, scheme2)
        XCTAssertEqual(format, format2)
    case (.oauth2(let flows), .oauth2(let flows2)):
        XCTAssertEqual(flows, flows2)
    case (.openIdConnect(let url), .openIdConnect(let url2)):
        XCTAssertEqual(url, url2)
    case (.mutualTLS, _):
        XCTFail("New Security requirement had type Mutual TLS which was not supported for OpenAPI 3.0.x.")
    default:
        XCTFail("New and old security schemes were of different cases. \(newScheme)    /    \(oldScheme)")
    }
}

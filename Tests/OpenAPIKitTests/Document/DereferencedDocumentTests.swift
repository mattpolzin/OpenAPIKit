//
//  DereferencedDocumentTests.swift
//  

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import XCTest
import OpenAPIKit

final class DereferencedDocumentTests: XCTestCase {
    func test_noSecurityOrPaths() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        ).locallyDereferenced()

        // test that dynamic member lookup works:
        XCTAssertEqual(t1.info, .init(title: "test", version: "1.0"))
    }

    func test_noSecurityInlinePath() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [
                "/hello/world": .init(
                  servers: [.init(urlTemplate: URLTemplate(rawValue: "http://{domain}.com")!, variables: ["domain": .init(default: "other")])],
                    get: .init(
                        operationId: "hi",
                        responses: [
                            200: .response(description: "success")
                        ]
                    )
                )
            ],
            components: .noComponents,
            tags: ["hi"]
        ).locallyDereferenced()

        XCTAssertEqual(t1.paths.count, 1)
        XCTAssertEqual(t1.paths["/hello/world"]?.get?.responses[status: 200]?.description, "success")

        // just check that you can snag the expected resolved endpoints
        XCTAssertEqual(
            t1.resolvedEndpoints().map { $0.path },
            ["/hello/world"]
        )

        XCTAssertEqual(
            t1.resolvedEndpointsByPath().keys,
            ["/hello/world"]
        )

        XCTAssertEqual(t1.allOperationIds, ["hi"])
        XCTAssertEqual(t1.allServers, [
            .init(url: URL(string: "http://website.com")!),
            .init(urlTemplate: URLTemplate(rawValue: "http://{domain}.com")!, variables: ["domain": .init(default: "other")]),
        ])
        XCTAssertEqual(t1.allTags, ["hi"])
    }

    func test_noSecurityReferencedResponseInPath() throws {
        let components = OpenAPI.Components.direct(
            responses: [
                "test": .init(description: "success")
            ]
        )
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .reference(.component(named: "test"))
                        ]
                    )
                )
            ],
            components: components
        ).locallyDereferenced()

        XCTAssertEqual(t1.paths.count, 1)
        XCTAssertEqual(t1.paths["/hello/world"]?.get?.responses[status: 200]?.description, "success")

        XCTAssertEqual(t1.routes.first?.path, "/hello/world")
        XCTAssertNotNil(t1.routes.first?.pathItem.get)
    }

    func test_securityAndReferencedResponseInPath() throws {
        let components = OpenAPI.Components.direct(
            responses: [
                "test": .init(description: "success")
            ],
            securitySchemes: [
                "test": .apiKey(name: "Api-Key", location: .header)
            ]
        )
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .reference(.component(named: "test"))
                        ]
                    )
                )
            ],
            components: components,
            security: [[.component(named: "test"): []]]
        ).locallyDereferenced()

        XCTAssertEqual(t1.paths.count, 1)
        XCTAssertEqual(t1.paths["/hello/world"]?.get?.responses[status: 200]?.description, "success")

        XCTAssertEqual(t1.security.count, 1)
        XCTAssertEqual(t1.security.first?.schemes["test"]?.securityScheme.type, .apiKey(name: "Api-Key", location: .header))
    }

    func test_locallyDereferencedResolvesSchemaAnchorReferences() throws {
        let anchoredChild = JSONSchema.string(
            .init(anchor: "nameAnchor"),
            .init()
        )
        let anchoredSchema = JSONSchema.object(
            properties: [
                "name": .reference(.anchor(named: "nameAnchor"))
            ],
            defs: [
                "nameDefinition": anchoredChild
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .pathItem(
                    .init(
                        get: .init(
                            responses: [
                                200: .response(
                                    description: "success",
                                    content: [
                                        OpenAPI.ContentType.json: .content(
                                            .init(
                                                schema: .reference(.component(named: "anchoredSchema"))
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                )
            ],
            components: .direct(
                schemas: [
                    "anchoredSchema": anchoredSchema
                ]
            )
        )

        let dereferencedDocument = try document.locallyDereferenced()
        let schema = dereferencedDocument
            .paths["/hello"]?
            .get?
            .responses[status: 200]?
            .content[OpenAPI.ContentType.json]?
            .schema

        let nameSchema = schema?.objectContext?.properties["name"]
        XCTAssertEqual(nameSchema?.jsonType, .string)
        XCTAssertEqual(nameSchema?.anchor, "nameAnchor")
    }

    func test_locallyDereferencedResolvesAnchorsCollectedAcrossDocumentLocations() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .pathItem(
                    .init(
                        get: .init(
                            responses: [
                                200: .response(
                                    description: "success",
                                    content: [
                                        .json: .content(
                                            .init(
                                                schema: .object(
                                                    properties: [
                                                        "parameter": .reference(.anchor(named: "parameterAnchor")),
                                                        "request": .reference(.anchor(named: "requestAnchor")),
                                                        "response": .reference(.anchor(named: "responseAnchor")),
                                                        "header": .reference(.anchor(named: "headerAnchor")),
                                                        "webhook": .reference(.anchor(named: "webhookAnchor")),
                                                        "mediaType": .reference(.anchor(named: "mediaTypeAnchor")),
                                                        "encodingHeader": .reference(.anchor(named: "encodingHeaderAnchor"))
                                                    ]
                                                )
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                )
            ],
            webhooks: [
                "event": .pathItem(
                    .init(
                        post: .init(
                            responses: [
                                200: .response(
                                    description: "webhook success",
                                    content: [
                                        .json: .content(
                                            .init(
                                                schema: .number(.init(anchor: "webhookAnchor"), .init())
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                )
            ],
            components: .direct(
                schemas: [
                    "__openapikit_anchor_0_776562686f6f6b416e63686f72": .string
                ],
                responses: [
                    "anchoredResponse": .init(
                        description: "anchored response",
                        content: [
                            .json: .content(
                                .init(
                                    schema: .boolean(.init(anchor: "responseAnchor"))
                                )
                            )
                        ]
                    )
                ],
                parameters: [
                    "anchoredParameter": .query(
                        name: "kind",
                        schema: .string(.init(anchor: "parameterAnchor"), .init())
                    )
                ],
                requestBodies: [
                    "anchoredRequest": .init(
                        content: [
                            .json: .content(
                                .init(
                                    schema: .integer(.init(anchor: "requestAnchor"), .init())
                                )
                            )
                        ]
                    )
                ],
                headers: [
                    "anchoredHeader": .init(
                        schema: .string(.init(anchor: "headerAnchor"), .init())
                    )
                ],
                mediaTypes: [
                    "anchoredMediaType": .init(
                        schema: .number(.init(anchor: "mediaTypeAnchor"), .init()),
                        encoding: [
                            "payload": .init(
                                headers: [
                                    "anchoredEncodingHeader": .b(
                                        .init(
                                            schema: .integer(.init(anchor: "encodingHeaderAnchor"), .init())
                                        )
                                    )
                                ]
                            )
                        ]
                    )
                ]
            )
        )

        let dereferencedDocument = try document.locallyDereferenced()
        let schema = try XCTUnwrap(
            dereferencedDocument
                .paths["/hello"]?
                .get?
                .responses[status: 200]?
                .content[OpenAPI.ContentType.json]?
                .schema
        )

        XCTAssertEqual(schema.objectContext?.properties["parameter"]?.jsonType, .string)
        XCTAssertEqual(schema.objectContext?.properties["request"]?.jsonType, .integer)
        XCTAssertEqual(schema.objectContext?.properties["response"]?.jsonType, .boolean)
        XCTAssertEqual(schema.objectContext?.properties["header"]?.jsonType, .string)
        XCTAssertEqual(schema.objectContext?.properties["webhook"]?.jsonType, .number)
        XCTAssertEqual(schema.objectContext?.properties["mediaType"]?.jsonType, .number)
        XCTAssertEqual(schema.objectContext?.properties["encodingHeader"]?.jsonType, .integer)
    }

    func test_locallyDereferencedResolvesSchemaAnchorReferencesFromPrefixItems() throws {
        let anchoredTupleChild = JSONSchema.string(
            .init(anchor: "tupleAnchor"),
            .init()
        )
        let anchoredSchema = JSONSchema.array(
            .init(),
            .init(
                prefixItems: [
                    anchoredTupleChild
                ]
            )
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .pathItem(
                    .init(
                        get: .init(
                            responses: [
                                200: .response(
                                    description: "success",
                                    content: [
                                        .json: .content(
                                            .init(
                                                schema: .reference(.anchor(named: "tupleAnchor"))
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                )
            ],
            components: .direct(
                schemas: [
                    "anchoredTupleSchema": anchoredSchema
                ]
            )
        )

        let dereferencedDocument = try document.locallyDereferenced()
        let schema = dereferencedDocument
            .paths["/hello"]?
            .get?
            .responses[status: 200]?
            .content[.json]?
            .schema

        XCTAssertEqual(schema?.jsonType, .string)
        XCTAssertEqual(schema?.anchor, "tupleAnchor")
    }

    func test_locallyDereferencedResolvesSchemaAnchorReferencesFromPatternProperties() throws {
        let anchoredPatternChild = JSONSchema.string(
            .init(anchor: "patternAnchor"),
            .init()
        )
        let anchoredSchema = JSONSchema.object(
            patternProperties: [
                "^x-": anchoredPatternChild
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .pathItem(
                    .init(
                        get: .init(
                            responses: [
                                200: .response(
                                    description: "success",
                                    content: [
                                        .json: .content(
                                            .init(
                                                schema: .reference(.anchor(named: "patternAnchor"))
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                )
            ],
            components: .direct(
                schemas: [
                    "anchoredPatternSchema": anchoredSchema
                ]
            )
        )

        let dereferencedDocument = try document.locallyDereferenced()
        let schema = dereferencedDocument
            .paths["/hello"]?
            .get?
            .responses[status: 200]?
            .content[.json]?
            .schema

        XCTAssertEqual(schema?.jsonType, .string)
        XCTAssertEqual(schema?.anchor, "patternAnchor")
    }

    func test_locallyDereferencedFailsOnDuplicateSchemaAnchors() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .pathItem(
                    .init(
                        get: .init(
                            responses: [
                                200: .response(
                                    description: "success",
                                    content: [
                                        .json: .content(
                                            .init(
                                                schema: .reference(.anchor(named: "duplicateAnchor"))
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                )
            ],
            components: .direct(
                schemas: [
                    "first": .string(.init(anchor: "duplicateAnchor"), .init()),
                    "second": .integer(.init(anchor: "duplicateAnchor"), .init())
                ]
            )
        )

        XCTAssertThrowsError(try document.locallyDereferenced()) { error in
            XCTAssertEqual(
                error as? OpenAPI.Document.DuplicateAnchorError,
                .init(name: "duplicateAnchor")
            )
            XCTAssertEqual(
                (error as? OpenAPI.Document.DuplicateAnchorError)?.description,
                "Encountered multiple JSON Schema $anchor definitions named 'duplicateAnchor' while preparing a locally dereferenced document. OpenAPIKit cannot determine which schema '#duplicateAnchor' should resolve to."
            )
        }
    }
}

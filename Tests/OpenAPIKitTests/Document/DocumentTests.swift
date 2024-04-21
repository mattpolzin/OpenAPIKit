//
//  DocumentTests.swift
//  
//
//  Created by Mathew Polzin on 10/27/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class DocumentTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.Document(
            info: .init(title: "hi", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let _ = OpenAPI.Document(
            openAPIVersion: .v3_1_0,
            info: .init(title: "hi", version: "1.0"),
            servers: [
                .init(url: URL(string: "https://google.com")!)
            ],
            paths: [
                "/hi/there": .init(
                    parameters: [],
                    get: .init(
                        tags: "hi",
                        parameters: [],
                        responses: [:]
                    )
                )
            ],
            components: .init(schemas: ["hello": .string]),
            security: [],
            tags: ["hi"],
            externalDocs: .init(url: URL(string: "https://google.com")!)
        )
    }

    func test_getRoutes() {
        let pi1 = OpenAPI.PathItem(
            parameters: [],
            get: .init(
                tags: "hi",
                parameters: [],
                responses: [:]
            )
        )

        let pi2 = OpenAPI.PathItem(
            get: .init(
                responses: [:]
            )
        )

        let test = OpenAPI.Document(
            info: .init(title: "hi", version: "1.0"),
            servers: [
                .init(url: URL(string: "https://google.com")!)
            ],
            paths: [
                "/hi/there": .pathItem(pi1),
                "/hi": .pathItem(pi2)
            ],
            components: .init(schemas: ["hello": .string])
        )

        XCTAssertEqual(
            test.routes,
            [
                .init(path: "/hi/there", pathItem: pi1),
                .init(path: "/hi", pathItem: pi2)
            ]
        )
    }

    func test_getAllOperationIds() {
        let t1 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: nil, responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: nil, responses: [:]))
            ],
            components: .noComponents
        )

        XCTAssertEqual(t1.allOperationIds, [])

        let t2 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: nil, responses: [:]))
            ],
            components: .noComponents
        )

        XCTAssertEqual(t2.allOperationIds, ["test"])

        let t3 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [:]))
            ],
            components: .noComponents
        )

        XCTAssertEqual(t3.allOperationIds, ["test", "two"])

        let t4 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: nil, responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [:]))
            ],
            components: .noComponents
        )

        XCTAssertEqual(t4.allOperationIds, ["two"])
    }

    func test_allServersEmpty() {
        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    servers: [],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: []
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [])
    }

    func test_allServers_onlyRoot() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [s1, s2],
            paths: [
                "/hello/world": .init(
                    servers: [],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: []
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2])
    }

    func test_allServers_onlyPathItem() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    servers: [s1, s2],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: []
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2])
    }

    func test_allServers_onlyOperation() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    servers: [],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: [s1, s2]
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2])
    }

    func test_allServers_allDuplicates() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [s1, s2],
            paths: [
                "/hello/world": .init(
                    servers: [s1, s2],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: [s1, s2]
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2])
    }

    func test_allServers_distributedThroughout() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)
        let s3 = OpenAPI.Server(url: URL(string: "https://website3.com")!)

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [s1],
            paths: [
                "/hello/world": .init(
                    servers: [s2],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: [s3]
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2, s3])
    }

    func test_allServers_descriptionDoesNotFactorIn() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)
        let s3 = OpenAPI.Server(url: URL(string: "https://website.com")!, description: "test")
        let s4 = OpenAPI.Server(url: URL(string: "https://website2.com")!, description: "test2")

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [s1],
            paths: [
                "/hello/world": .init(
                    servers: [s2, s4],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: [s3]
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2])
    }

    func test_allServers_variablesDoFactorIn() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)
        let s3 = OpenAPI.Server(url: URL(string: "https://website.com")!, variables: ["hi": .init(default: "there")])
        let s4 = OpenAPI.Server(url: URL(string: "https://website.com")!, variables: ["hi": .init(default: "again")])

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [s1],
            paths: [
                "/hello/world": .init(
                    servers: [s2, s4],
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])],
                        servers: [s3]
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2, s4, s3])
    }

    func test_allServers_nilIsEmptyServers() {
        let s1 = OpenAPI.Server(url: URL(string: "https://website.com")!)
        let s2 = OpenAPI.Server(url: URL(string: "https://website2.com")!)

        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [s1, s2],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [.default: .response(description: "test", content: [.json: .init(schema: .string)])]
                    )
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t.allServers, [s1, s2])
    }

    func test_pathFiltering() {
        let t = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/test1": .init(),
                "/test2": .init()
            ],
            components: .noComponents
        )

        let t2 = t.filteringPaths(with: { $0 == "/test1" })

        XCTAssertEqual(t.paths.count, 2)
        XCTAssertEqual(t2.paths.count, 1)
        XCTAssertNotNil(t2.paths["/test1"])
    }

    func test_existingSecuritySchemeSuccess() {
        let docData =
        """
        {
            "openapi": "3.1.0",
            "info": {
                "title": "test",
                "version": "1.0"
            },
            "paths": {},
            "components": {
                "securitySchemes": {
                    "found": {
                        "type": "http",
                        "scheme": "basic"
                    }
                }
            },
            "security": [
                {
                    "found": []
                }
            ]
        }
        """.data(using: .utf8)!

        XCTAssertNoThrow(try orderUnstableDecode(OpenAPI.Document.self, from: docData))
    }
}

// MARK: - Codable
extension DocumentTests {
    func test_minimal_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0"
            }
            """
        )
    }

    func test_minimal_decode() throws {
        let documentData =
        """
        {
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          }
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents
            )
        )
    }

    func test_specifyOpenAPIVersion_encode() throws {
        let document = OpenAPI.Document(
            openAPIVersion: .v3_1_0,
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0"
            }
            """
        )
    }

    func test_specifyOpenAPIVersion_decode() throws {
        let documentData =
        """
        {
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          }
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                openAPIVersion: .v3_1_0,
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents
            )
        )
    }

    func test_specifyServers_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [.init(url: URL(string: "http://google.com")!)],
            paths: [:],
            components: .noComponents
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0",
              "servers" : [
                {
                  "url" : "http:\\/\\/google.com"
                }
              ]
            }
            """
        )
    }

    func test_specifyServers_decode() throws {
        let documentData =
        """
        {
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          },
          "servers" : [
            {
              "url" : "http:\\/\\/google.com"
            }
          ]
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [.init(url: URL(string: "http://google.com")!)],
                paths: [:],
                components: .noComponents
            )
        )
    }

    func test_specifyPaths_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: ["test": .init(summary: "hi")],
            components: .noComponents
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0",
              "paths" : {
                "\\/test" : {
                  "summary" : "hi"
                }
              }
            }
            """
        )
    }

    func test_specifyPaths_decode() throws {
        let documentData =
        """
        {
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {
            "\\/test" : {
              "summary" : "hi"
            }
          }
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: ["test": .init(summary: "hi")],
                components: .noComponents
            )
        )
    }

    func test_specifySecurity_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .init(
                securitySchemes: ["security": .init(type: .apiKey(name: "key", location: .header))]
            ),
            security: [[.component( named: "security"):[]]]
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "components" : {
                "securitySchemes" : {
                  "security" : {
                    "in" : "header",
                    "name" : "key",
                    "type" : "apiKey"
                  }
                }
              },
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0",
              "security" : [
                {
                  "security" : [

                  ]
                }
              ]
            }
            """
        )
    }

    func test_specifySecurity_decode() throws {
        let documentData =
        """
        {
          "components" : {
            "securitySchemes" : {
              "security" : {
                "in" : "header",
                "name" : "key",
                "type" : "apiKey"
              }
            }
          },
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          },
          "security" : [
            {
              "security" : [

              ]
            }
          ]
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .init(
                    securitySchemes: ["security": .init(type: .apiKey(name: "key", location: .header))]
                ),
                security: [[.component( named: "security"):[]]]
            )
        )
    }

    func test_specifyTags_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: [.init(name: "hi")]
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0",
              "tags" : [
                {
                  "name" : "hi"
                }
              ]
            }
            """
        )
    }

    func test_specifyTags_decode() throws {
        let documentData =
        """
        {
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          },
          "tags" : [
            {
              "name" : "hi"
            }
          ]
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents,
                tags: [.init(name: "hi")]
            )
        )
    }

    func test_specifyExternalDocs_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            externalDocs: .init(url: URL(string: "http://google.com")!)
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "externalDocs" : {
                "url" : "http:\\/\\/google.com"
              },
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0"
            }
            """
        )
    }

    func test_specifyExternalDocs_decode() throws {
        let documentData =
        """
        {
          "externalDocs" : {
            "url" : "http:\\/\\/google.com"
          },
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          }
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }

    func test_vendorExtensions_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            externalDocs: .init(url: URL(string: "http://google.com")!),
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
            """
            {
              "externalDocs" : {
                "url" : "http:\\/\\/google.com"
              },
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.0",
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_vendorExtensions_decode() throws {
        let documentData =
        """
        {
          "externalDocs" : {
            "url" : "http:\\/\\/google.com"
          },
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          },
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!),
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
            )
        )
    }

    func test_jsonSchemaDialect_encode() throws {
        // TODO: once implemented (https://github.com/mattpolzin/OpenAPIKit/issues/202)
    }

    func test_jsonSchemaDialect_decode() throws {
        let documentData =
        """
        {
          "externalDocs" : {
            "url" : "http:\\/\\/google.com"
          },
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "paths" : {

          },
          "jsonSchemaDialect" : "http://json-schema.org/draft/2020-12/schema"
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }
}

// MARK: - Webhooks
extension DocumentTests {
    
    func test_webhooks_encode() throws {
        let op = OpenAPI.Operation(responses: [:])
        let pathItem: OpenAPI.PathItem = .init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op)
        let pathItemTest: Either<OpenAPI.Reference<OpenAPI.PathItem>, OpenAPI.PathItem> = .pathItem(pathItem)
        
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            webhooks:  [
                "webhook-test": pathItemTest
            ],
            components: .noComponents,
            externalDocs: .init(url: URL(string: "http://google.com")!)
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        let documentJSON: String? =
            """
        {
          "externalDocs" : {
            "url" : "http:\\/\\/google.com"
          },
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "webhooks" : {
            "webhook-test" : {
              "delete" : {

              },
              "get" : {

              },
              "head" : {

              },
              "options" : {

              },
              "patch" : {

              },
              "post" : {

              },
              "put" : {

              },
              "trace" : {

              }
            }
          }
        }
        """

        assertJSONEquivalent(encodedDocument, documentJSON)
    }
    
  func test_webhooks_encode_decode() throws {
    let op = OpenAPI.Operation(responses: [:])
    let pathItem = OpenAPI.PathItem(get: op, put: op, post: op, options: op, head: op, patch: op, trace: op)

      let document = OpenAPI.Document(
        info: .init(title: "API", version: "1.0"),
        servers: [],
        paths: [:],
        webhooks:  [
            "webhook-test": .pathItem(pathItem)
        ],
        components: .noComponents,
        externalDocs: .init(url: URL(string: "http://google.com")!)
      )
    
    // INFO: `assertJSONEquivalent` was returning `false` for equivalent documets, so encode-decode was used for comparison -
      let encodedDocumentString = try orderUnstableTestStringFromEncoding(of: document)
      let encodedDocumentData = (encodedDocumentString?.data(using: .utf8)!)!
      let decodedDocument = try orderUnstableDecode(OpenAPI.Document.self, from: encodedDocumentData)
      XCTAssertEqual(document, decodedDocument)
  }
  
  func test_webhooks_decode() throws {
      let documentData =
      """
      {
        "externalDocs": {
          "url": "http:\\/\\/google.com"
        },
        "info": {
          "title": "API",
          "version": "1.0"
        },
        "openapi": "3.1.0",
        "paths": {
        },
        "webhooks": {
          "webhook-test": {
            "delete": {
            },
            "get": {
            },
            "head": {
            },
            "options": {
            },
            "patch": {
            },
            "post": {
            },
            "put": {
            },
            "trace": {
            }
          }
        }
      }
      """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)
        
        let op = OpenAPI.Operation(responses: [:])
        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                webhooks:  [
                    "webhook-test": .init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op)
                ],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }
    
    func test_webhooks_noPaths_encode() throws {
        let op = OpenAPI.Operation(responses: [:])
        let pathItem: OpenAPI.PathItem = .init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op)
        let pathItemTest: Either<OpenAPI.Reference<OpenAPI.PathItem>, OpenAPI.PathItem> = .pathItem(pathItem)
        
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            webhooks:  [
                "webhook-test": pathItemTest
            ],
            components: .noComponents,
            externalDocs: .init(url: URL(string: "http://google.com")!)
        )
        let encodedDocument = try orderUnstableTestStringFromEncoding(of: document)

        let documentJSON: String? =
            """
        {
          "externalDocs" : {
            "url" : "http:\\/\\/google.com"
          },
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.0",
          "webhooks" : {
            "webhook-test" : {
              "delete" : {

              },
              "get" : {

              },
              "head" : {

              },
              "options" : {

              },
              "patch" : {

              },
              "post" : {

              },
              "put" : {

              },
              "trace" : {

              }
            }
          }
        }
        """

        assertJSONEquivalent(encodedDocument, documentJSON)
    }
    
  func test_webhooks_noPaths_decode() throws {
      let documentData =
      """
      {
        "externalDocs": {
          "url": "http:\\/\\/google.com"
        },
        "info": {
          "title": "API",
          "version": "1.0"
        },
        "openapi": "3.1.0",
        "webhooks": {
          "webhook-test": {
            "delete": {
            },
            "get": {
            },
            "head": {
            },
            "options": {
            },
            "patch": {
            },
            "post": {
            },
            "put": {
            },
            "trace": {
            }
          }
        }
      }
      """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)
        
        let op = OpenAPI.Operation(responses: [:])
        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                webhooks:  [
                    "webhook-test": .pathItem(.init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op))
                ],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }
}

// MARK: - External Dereferencing
extension DocumentTests {
    // temporarily test with an example of the new interface
    func test_example() async throws {

        /// An example of implementing a loader context for loading external references
        /// into an OpenAPI document.
        struct ExampleLoader: ExternalLoader {
            static func load<T>(_ url: URL) async throws -> T where T : Decodable {
                // load data from file, perhaps. we will just mock that up for the test:
                let data = try await mockData(componentKey(type: T.self, at: url))

                let decoded = try JSONDecoder().decode(T.self, from: data)
                let finished: T
                // while unnecessary, a loader may likely want to attatch some extra info
                // to keep track of where a reference was loaded from. This test makes sure
                // the following strategy of using vendor extensions works.
                if var extendable = decoded as? VendorExtendable {
                    extendable.vendorExtensions["x-source-url"] = AnyCodable(url)
                    finished = extendable as! T
                } else {
                    finished = decoded 
                }
                return finished
            }

            static func componentKey<T>(type: T.Type, at url: URL) throws -> OpenAPIKit.OpenAPI.ComponentKey {
                // do anything you want here to determine what key the new component should be stored at.
                // for the example, we will just transform the URL into a valid components key:
                let urlString = url.pathComponents.dropFirst()
                  .joined(separator: "_")
                  .replacingOccurrences(of: ".", with: "_")
                return try .forceInit(rawValue: urlString)
            }

            /// Mock up some data, just for the example. 
            static func mockData(_ key: OpenAPIKit.OpenAPI.ComponentKey) async throws -> Data {
                print("looking up \(key.rawValue)")
                return try XCTUnwrap(files[key.rawValue])
            }

            static let files: [String: Data] = [
                "params_name_json": """
                {
                    "name": "name",
                    "description": "a lonely parameter",
                    "in": "path",
                    "required": true,
                    "schema": {
                        "$ref": "file://./schemas/name_param.json#"
                    }
                }
                """,
                "schemas_name_param_json": """
                {
                    "type": "string"
                }
                """
            ].mapValues { $0.data(using: .utf8)! }
        }

        var document = OpenAPI.Document(
           info: .init(title: "test document", version: "1.0.0"),
           servers: [],
           paths: [
               "/hello/{name}": .init(
                   parameters: [
                       .reference(.external(URL(string: "file://./params/name.json")!))
                   ]
               ),
               "/goodbye/{name}": .init(
                   parameters: [
                       .reference(.external(URL(string: "file://./params/name.json")!))
                   ]
               )
            ],
           components: .init(
               // just to show, no parameters defined within document components :
               parameters: [:]
           )
        )

       let encoder = JSONEncoder()
       encoder.outputFormatting = .prettyPrinted

       // - MARK: Before 
       print(
           String(data: try encoder.encode(document), encoding: .utf8)!
       )
       /*
        {
          "openapi": "3.1.0",
          "info": {
            "title": "test document",
            "version": "1.0.0"
          },
          "paths": {
            "\/hello\/{name}": {
              "parameters": [
                {
                  "$ref": "file:\/\/.\/params\/name.json"
                }
              ]
            }
          }
        }
       */

       try await document.externallyDereference(in: ExampleLoader.self)

       // - MARK: After
       print(
           String(data: try encoder.encode(document), encoding: .utf8)!
       )
       /*
        {
          "paths": {
            "\/hello\/{name}": {
              "parameters": [
                {
                  "$ref": "#\/components\/parameters\/params_name_json"
                }
              ]
            }
          },
          "components": {
            "parameters": {
              "params_name_json": {
                "x-source-url": "file:\/\/.\/params\/name.json",
                "in": "path",
                "name": "name",
                "required": true,
                "schema": {
                  "type": "string"
                }
              }
            }
          },
          "openapi": "3.1.0",
          "info": {
            "title": "test document",
            "version": "1.0.0"
          }
        }
       */
    }
}

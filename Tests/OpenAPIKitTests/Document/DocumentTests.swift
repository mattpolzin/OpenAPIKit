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
            selfURI: .init(string: "https://example.com/openapi")!,
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

    func test_initOASVersions() {
        let t1 = OpenAPI.Document.Version.v3_1_0
        XCTAssertEqual(t1.rawValue, "3.1.0")

        let t2 = OpenAPI.Document.Version.v3_1_1
        XCTAssertEqual(t2.rawValue, "3.1.1")

        let t3 = OpenAPI.Document.Version.v3_1_2
        XCTAssertEqual(t3.rawValue, "3.1.2")

        let t4 = OpenAPI.Document.Version.v3_1_x(x: 8)
        XCTAssertEqual(t4.rawValue, "3.1.8")

        let t5 = OpenAPI.Document.Version.v3_2_0
        XCTAssertEqual(t5.rawValue, "3.2.0")

        let t6 = OpenAPI.Document.Version(rawValue: "3.1.0")
        XCTAssertEqual(t6, .v3_1_0)

        let t7 = OpenAPI.Document.Version(rawValue: "3.1.1")
        XCTAssertEqual(t7, .v3_1_1)

        let t8 = OpenAPI.Document.Version(rawValue: "3.1.2")
        XCTAssertEqual(t8, .v3_1_2)

        // not a known version:
        let t9 = OpenAPI.Document.Version(rawValue: "3.1.8")
        XCTAssertNil(t9)

        let t10 = OpenAPI.Document.Version(rawValue: "3.2.8")
        XCTAssertNil(t10)
    }

    func test_compareOASVersions() {
        let versions: [OpenAPI.Document.Version] = [
          .v3_1_0,
          .v3_1_1,
          .v3_1_2,
          .v3_2_0
        ]

        for v1Idx in 0...(versions.count - 2) {
            for v2Idx in (v1Idx + 1)...(versions.count - 1) {
                XCTAssert(versions[v1Idx] < versions[v2Idx])
            }
        }
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
        // paths, no operation ids, no components, no webhooks
        let t1 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: nil, responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: nil, responses: [:])),
                "/hi/mom": .init(
                    additionalOperations: [
                      "LINK": .init(operationId: nil, responses: [:])
                    ]
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t1.allOperationIds, [])

        // paths, one operation id (second one nil), no components, no webhooks
        let t2 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: nil, responses: [:])),
                "/hi/mom": .init(
                    additionalOperations: [
                      "LINK": .init(operationId: nil, responses: [:])
                    ]
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t2.allOperationIds, ["test"])

        // paths, multiple operation ids, no components, no webhooks
        let t3 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [:])),
                "/hi/mom": .init(
                    additionalOperations: [
                      "LINK": .init(operationId: "three", responses: [:])
                    ]
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t3.allOperationIds, ["test", "two", "three"])

        // paths, one operation id (first one nil), no components, no webhooks
        let t4 = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: nil, responses: [:])),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [:])),
                "/hi/mom": .init(
                    additionalOperations: [
                      "LINK": .init(operationId: nil, responses: [:])
                    ]
                )
            ],
            components: .noComponents
        )

        XCTAssertEqual(t4.allOperationIds, ["two"])

        // paths, one operation id, one component reference, no webhooks
        let t5 = OpenAPI.Document(
          info: .init(title: "test", version: "1.0"),
          servers: [],
          paths: [
            "/hello": .init(
              get: .init(operationId: "test", responses: [:])),
            "/hello/world": .reference(.component(named: "hello-world"))
          ],
          components: .init(
              pathItems: ["hello-world": .init(put: .init(operationId: "two", responses: [:]))]
          )
        )

        XCTAssertEqual(t5.allOperationIds, ["test", "two"])

        // no paths, one webhook with an operation id
        let t6 = OpenAPI.Document(
          info: .init(title: "test", version: "1.0"),
          servers: [],
          paths: [:],
          webhooks: [
            "/hello": .init(
              get: .init(operationId: "test", responses: [:]))
          ],
          components: .noComponents
        )

        XCTAssertEqual(t6.allOperationIds, ["test"])
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
            "openapi": "3.1.1",
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
              "openapi" : "3.1.1"
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
          "openapi" : "3.1.1",
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

    func test_specifyUknownOpenAPIVersion_encode() throws {
        let document = OpenAPI.Document(
          openAPIVersion: .v3_1_x(x: 9),
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
                      "openapi" : "3.1.9"
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

    func test_specifyUnknownOpenAPIVersion_decode() throws {
        let documentData =
                """
                {
                  "info" : {
                    "title" : "API",
                    "version" : "1.0"
                  },
                  "openapi" : "3.1.9",
                  "paths" : {
                
                  }
                }
                """.data(using: .utf8)!
        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.Document.self, from: documentData)) { error in XCTAssertEqual(OpenAPI.Error(from: error).localizedDescription, "Problem encountered when parsing `openapi` in the root Document object: Failed to parse Document Version 3.1.9 as one of OpenAPIKit's supported options.") }
    }

    func test_unsupportedButMappedOpenAPIVersion_decode() throws {
        let documentData =
                """
                {
                  "info" : {
                    "title" : "API",
                    "version" : "1.0"
                  },
                  "openapi" : "3.100.100",
                  "paths" : {
                
                  }
                }
                """.data(using: .utf8)!
        let userInfo = [
            DocumentConfiguration.versionMapKey: ["3.100.100": OpenAPI.Document.Version.v3_1_1]
        ]
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData, userInfo: userInfo)
        XCTAssertEqual(document.warnings.map { $0.localizedDescription }, ["Document Version 3.100.100 is being decoded as version 3.1.1. Not all features of OAS 3.100.100 will be supported"])
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
              "openapi" : "3.1.1",
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
          "openapi" : "3.1.1",
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

    func test_specifySelfURI_encode() throws {
        let document = OpenAPI.Document(
            selfURI: .init(string: "https://example.com/openapi")!,
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
              "$self" : "https:\\/\\/example.com\\/openapi",
              "info" : {
                "title" : "API",
                "version" : "1.0"
              },
              "openapi" : "3.1.1"
            }
            """
        )
    }

    func test_specifySelfURI_decode() throws {
        let documentData =
        """
        {
          "$self": "https://example.com/openapi",
          "info" : {
            "title" : "API",
            "version" : "1.0"
          },
          "openapi" : "3.1.1",
          "paths" : {

          }
        }
        """.data(using: .utf8)!
        let document = try orderUnstableDecode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                selfURI: .init(string: "https://example.com/openapi")!,
                info: .init(title: "API", version: "1.0"),
                servers: [],
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
              "openapi" : "3.1.1",
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
          "openapi" : "3.1.1",
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
              "openapi" : "3.1.1",
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
          "openapi" : "3.1.1",
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
              "openapi" : "3.1.1",
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
          "openapi" : "3.1.1",
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
              "openapi" : "3.1.1"
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
          "openapi" : "3.1.1",
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
            vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
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
              "openapi" : "3.1.1",
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
          "openapi" : "3.1.1",
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
                vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
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
          "openapi" : "3.1.1",
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
        let pathItem: OpenAPI.PathItem = .init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op, query: op)
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
          "openapi" : "3.1.1",
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
              "query" : {

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
    let pathItem = OpenAPI.PathItem(get: op, put: op, post: op, options: op, head: op, patch: op, trace: op, query: op)

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
        "openapi": "3.1.1",
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
            },
            "query": {
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
                    "webhook-test": .init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op, query: op)
                ],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }
    
    func test_webhooks_noPaths_encode() throws {
        let op = OpenAPI.Operation(responses: [:])
        let pathItem: OpenAPI.PathItem = .init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op, query: op)
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
          "openapi" : "3.1.1",
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
              "query" : {

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
        "openapi": "3.1.1",
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
            },
            "query": {
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
                    "webhook-test": .pathItem(.init(get: op, put: op, post: op, delete: op, options: op, head: op, patch: op, trace: op, query: op))
                ],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }
}

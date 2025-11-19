//
//  PathItemTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit
import Foundation

final class PathItemTests: XCTestCase {
    func test_initializePathComponents() {
        let t1 = OpenAPI.Path(["hello", "world"])
        let t2 = OpenAPI.Path(rawValue: "/hello/world")
        let t3 = OpenAPI.Path(rawValue: "hello/world")
        let t4: OpenAPI.Path = "/hello/world"
        let t5: OpenAPI.Path = "hello/world"
        let t6: OpenAPI.Path = "hello/world/"
        let t7 = OpenAPI.Path(["hello", "world"], trailingSlash: true)
        let t8 = OpenAPI.Path(rawValue: "/")
        
        XCTAssertEqual(t1, t2)
        XCTAssertEqual(t2, t3)
        XCTAssertEqual(t3, t4)
        XCTAssertEqual(t4, t5)
        XCTAssertNotEqual(t5,t6)
        XCTAssertEqual(t6, t7)

        XCTAssertEqual(t1.rawValue, "/hello/world")
        XCTAssertEqual(t2.rawValue, "/hello/world")
        XCTAssertEqual(t3.rawValue, "/hello/world")
        XCTAssertEqual(t4.rawValue, "/hello/world")
        XCTAssertEqual(t5.rawValue, "/hello/world")
        XCTAssertEqual(t6.rawValue, "/hello/world/")
        XCTAssertEqual(t8.rawValue, "/")
    }

    func test_initializePathItem() {
        // minimal
        let _ = OpenAPI.PathItem()

        // maximal
        let op = OpenAPI.Operation(responses: [:])
        let _ = OpenAPI.PathItem(
            summary: "summary",
            description: "description",
            servers: [OpenAPI.Server(url: URL(string: "http://google.com")!)],
            parameters: [.parameter(name: "hello", context: .query(schema: .string))],
            get: op,
            put: op,
            post: op,
            delete: op,
            options: op,
            head: op,
            patch: op,
            trace: op,
            query: op,
            additionalOperations: [
                "LINK": op
            ]
        )
    }

    func test_pathItemMutations() {
        let op = OpenAPI.Operation(responses: [:])

        // adding/removing paths
        var pathItem = OpenAPI.PathItem()
        XCTAssertNil(pathItem.get)
        XCTAssertNil(pathItem.put)
        XCTAssertNil(pathItem.post)
        XCTAssertNil(pathItem.delete)
        XCTAssertNil(pathItem.options)
        XCTAssertNil(pathItem.head)
        XCTAssertNil(pathItem.patch)
        XCTAssertNil(pathItem.trace)
        XCTAssertNil(pathItem.query)

        pathItem.get(op)
        XCTAssertEqual(pathItem.get, op)

        pathItem.get(nil)
        XCTAssertNil(pathItem.get)

        pathItem.put(op)
        XCTAssertEqual(pathItem.put, op)

        pathItem.post(op)
        XCTAssertEqual(pathItem.post, op)

        pathItem.delete(op)
        XCTAssertEqual(pathItem.delete, op)

        pathItem.options(op)
        XCTAssertEqual(pathItem.options, op)

        pathItem.head(op)
        XCTAssertEqual(pathItem.head, op)

        pathItem.patch(op)
        XCTAssertEqual(pathItem.patch, op)

        pathItem.trace(op)
        XCTAssertEqual(pathItem.trace, op)

        pathItem.query(op)
        XCTAssertEqual(pathItem.query, op)

        // for/set/subscript
        pathItem = .init()
        XCTAssertNil(pathItem[.get])
        XCTAssertNil(pathItem[.put])
        XCTAssertNil(pathItem[.post])
        XCTAssertNil(pathItem[.delete])
        XCTAssertNil(pathItem[.options])
        XCTAssertNil(pathItem[.head])
        XCTAssertNil(pathItem[.patch])
        XCTAssertNil(pathItem[.trace])
        XCTAssertNil(pathItem[.query])

        pathItem[.get] = op
        XCTAssertEqual(pathItem.for(.get), op)

        pathItem[.put] = op
        XCTAssertEqual(pathItem.for(.put), op)

        pathItem[.post] = op
        XCTAssertEqual(pathItem.for(.post), op)

        pathItem[.delete] = op
        XCTAssertEqual(pathItem.for(.delete), op)

        pathItem[.options] = op
        XCTAssertEqual(pathItem.for(.options), op)

        pathItem[.head] = op
        XCTAssertEqual(pathItem.for(.head), op)

        pathItem[.patch] = op
        XCTAssertEqual(pathItem.for(.patch), op)

        pathItem[.trace] = op
        XCTAssertEqual(pathItem.for(.trace), op)

        pathItem[.query] = op
        XCTAssertEqual(pathItem.for(.query), op)
    }

    func test_initializePathItemMap() {
        let _: OpenAPI.PathItem.Map = [
            "hello/world": .init(),
        ]
    }

    func test_endpointsAccessor() {
        let op = OpenAPI.Operation(responses: [:])
        let pathItem = OpenAPI.PathItem(
            summary: "summary",
            description: "description",
            servers: [OpenAPI.Server(url: URL(string: "http://google.com")!)],
            parameters: [.parameter(name: "hello", context: .query(schema: .string))],
            get: op,
            put: op,
            post: op,
            delete: op,
            options: op,
            head: op,
            patch: op,
            trace: op,
            query: op,
            additionalOperations: [
                "LINK": op
            ]
        )

        let expectedEndpoints : [EquatableEndpoint] = [
            .init(method: .get, operation: op),
            .init(method: .put, operation: op),
            .init(method: .post, operation: op),
            .init(method: .delete, operation: op),
            .init(method: .options, operation: op),
            .init(method: .head, operation: op),
            .init(method: .patch, operation: op),
            .init(method: .trace, operation: op),
            .init(method: .query, operation: op),
            .init(method: "LINK", operation: op)
        ]

        let actualEndpoints = pathItem.endpoints.map(equatableEndpoint)

        XCTAssertEqual(actualEndpoints.count, expectedEndpoints.count)
        for endpoint in expectedEndpoints {
            XCTAssert(actualEndpoints.contains(endpoint))
        }
    }
}

fileprivate struct EquatableEndpoint: Equatable {
    let method: OpenAPI.HttpMethod
    let operation: OpenAPI.Operation
}

fileprivate func equatableEndpoint(_ endpoint: OpenAPI.PathItem.Endpoint) -> EquatableEndpoint {
    return .init(method: endpoint.method, operation: endpoint.operation)
}

// MARK: Codable Tests
extension PathItemTests {
    func test_minimal_encode() throws {
        let pathItem = OpenAPI.PathItem()

        let encodedPathItem = try orderUnstableTestStringFromEncoding(of: pathItem)

        assertJSONEquivalent(
            encodedPathItem,
            """
            {

            }
            """
        )
    }

    func test_minimal_decode() throws {
        let pathItemData =
        """
        {

        }
        """.data(using: .utf8)!

        let pathItem = try orderUnstableDecode(OpenAPI.PathItem.self, from: pathItemData)

        XCTAssertEqual(pathItem, OpenAPI.PathItem())
    }

    func test_meta_encode() throws {
        let pathItem = OpenAPI.PathItem(
            summary: "summary",
            description: "description",
            servers: [OpenAPI.Server(url: URL(string: "http://google.com")!)],
            parameters: [.parameter(name: "hello", context: .query(schema: .string))],
            vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
        )

        let encodedPathItem = try orderUnstableTestStringFromEncoding(of: pathItem)

        assertJSONEquivalent(
            encodedPathItem,
            """
            {
              "description" : "description",
              "parameters" : [
                {
                  "in" : "query",
                  "name" : "hello",
                  "schema" : {
                    "type" : "string"
                  }
                }
              ],
              "servers" : [
                {
                  "url" : "http:\\/\\/google.com"
                }
              ],
              "summary" : "summary",
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_meta_decode() throws {
        let pathItemData =
        """
        {
          "description" : "description",
          "parameters" : [
            {
              "in" : "query",
              "name" : "hello",
              "schema" : {
                "type" : "string"
              }
            }
          ],
          "servers" : [
            {
              "url" : "http:\\/\\/google.com"
            }
          ],
          "summary" : "summary",
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!

        let pathItem = try orderUnstableDecode(OpenAPI.PathItem.self, from: pathItemData)

        XCTAssertEqual(
            pathItem,
            OpenAPI.PathItem(
                summary: "summary",
                description: "description",
                servers: [OpenAPI.Server(url: URL(string: "http://google.com")!)],
                parameters: [.parameter(name: "hello", context: .query(schema: .string))],
                vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
            )
        )
    }

    func test_operations_encode() throws {
        let op = OpenAPI.Operation(responses: [:])

        let pathItem = OpenAPI.PathItem(
            get: op,
            put: op,
            post: op,
            delete: op,
            options: op,
            head: op,
            patch: op,
            trace: op,
            query: op,
            additionalOperations: [
                "LINK": op
            ]
        )

        let encodedPathItem = try orderUnstableTestStringFromEncoding(of: pathItem)

        assertJSONEquivalent(
            encodedPathItem,
            """
            {
              "additionalOperations" : {
                "LINK" : {

                }
              },
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
            """
        )
    }

    func test_operations_decode() throws {
        let pathItemData =
        """
        {
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
          },
          "query" : {
          },
          "additionalOperations": {
            "LINK": {
            },
            "CONNECT": {
            },
            "unknown_method": {
            },
          }
        }
        """.data(using: .utf8)!

        let pathItem = try orderStableDecode(OpenAPI.PathItem.self, from: pathItemData)

        let op = OpenAPI.Operation(responses: [:])

        XCTAssertEqual(
            pathItem,
            OpenAPI.PathItem(
                get: op,
                put: op,
                post: op,
                delete: op,
                options: op,
                head: op,
                patch: op,
                trace: op,
                query: op,
                additionalOperations: [
                    "LINK": op,
                    "CONNECT": op,
                    "unknown_method": op
                ]
            )
        )
    }

    func test_disallowedAdditionalOperations_decode() throws {
        // NOTE the one allowed method in the following is LINK which is there
        // to ensure allowed methods do not show up in the error output.
        let pathItemData =
        """
        {
          "additionalOperations": {
            "LINK": {
            },
            "DELETE" : {
            },
            "GET" : {
            },
            "HEAD" : {
            },
            "OPTIONS" : {
            },
            "PATCH" : {
            },
            "POST" : {
            },
            "PUT" : {
            },
            "TRACE" : {
            },
            "QUERY" : {
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderStableDecode(OpenAPI.PathItem.self, from: pathItemData)) { error in
             XCTAssertEqual(String(describing: OpenAPI.Error(from: error)), "Problem encountered when parsing `additionalOperations` under the `/` path: Additional Operations cannot contain operations that can be set directly on the Path Item. Found the following disallowed additional operations: DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT, TRACE, QUERY.")
         } 
    }

    func test_invalidAdditionalOperation1_decode() throws {
        let pathItemData =
        """
        {
          "additionalOperations": {
            "connect": {
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.PathItem.self, from: pathItemData)) { error in
             XCTAssertEqual(String(describing: OpenAPI.Error(from: error)), "Problem encountered when parsing `connect` under the `/` path: 'connect' must be uppercased.")
         } 
    }

    func test_invalidAdditionalOperation2_decode() throws {
        let pathItemData =
        """
        {
          "additionalOperations": {
            "link": {
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.PathItem.self, from: pathItemData)) { error in
             XCTAssertEqual(String(describing: OpenAPI.Error(from: error)), "Problem encountered when parsing `link` under the `/` path: 'link' must be uppercased.")
         } 
    }

    func test_pathComponents_encode() throws {
        let test: [OpenAPI.Path] = ["/hello/world", "hi/there"]

        let encodedTest = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encodedTest,
            """
            [
              "\\/hello\\/world",
              "\\/hi\\/there"
            ]
            """
        )
    }

    func test_pathComponents_decode() throws {
        let testData =
        """
        [
          "\\/hello\\/world",
          "\\/hi\\/there"
        ]
        """.data(using: .utf8)!

        let test = try orderUnstableDecode([OpenAPI.Path].self, from: testData)

        XCTAssertEqual(
            test,
            [
                "/hello/world",
                "hi/there"
            ]
        )
    }

    func test_pathItemMap_encode() throws {
        let map: OpenAPI.PathItem.Map = [
            "/hello/world": .init(),
            "hi/there": .init(),
            "/reference/": .reference(.component(named: "pathRef"))
        ]

        let encodedMap = try orderUnstableTestStringFromEncoding(of: map)

        assertJSONEquivalent(
            encodedMap,
            """
            {
              "\\/hello\\/world" : {

              },
              "\\/hi\\/there" : {

              },
              "\\/reference\\/" : {
                "$ref" : "#\\/components\\/pathItems\\/pathRef"
              }
            }
            """
        )
    }

    func test_pathItemMap_decode() throws {
        let mapData =
        """
        {
          "\\/hello\\/world" : {

          },
          "\\/hi\\/there" : {

          },
          "\\/reference\\/" : {
            "$ref" : "#\\/components\\/pathItems\\/pathRef"
          }
        }
        """.data(using: .utf8)!

        let map = try orderStableDecode(OpenAPI.PathItem.Map.self, from: mapData)

        XCTAssertEqual(
            map,
            [
                "/hello/world": .init(),
                "/hi/there": .init(),
                "/reference/": .reference(.component(named: "pathRef"))
            ]
        )
    }
}

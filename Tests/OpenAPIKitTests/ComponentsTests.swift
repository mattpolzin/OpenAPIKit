//
//  ComponentsTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ComponentsTests: XCTestCase {
    typealias Components = OpenAPI.Components

    func test_isEmpty() {
        let c1 = Components.noComponents
        let c2 = Components()
        let c3 = Components(
            schemas: [
                "s1": .string
            ]
        )
        XCTAssertEqual(c1, c2)

        XCTAssertTrue(c1.isEmpty)
        XCTAssertFalse(c3.isEmpty)
    }

    func test_directConstructor() {
        let c1 = OpenAPI.Components(
            schemas: [
                "one": .string,
                "ref": .reference(.component(named: "one"))
            ],
            responses: [
                "two": .response(.init(description: "hello", content: [:]))
            ],
            parameters: [
                "three": .parameter(.init(name: "hi", context: .query(content: [:])))
            ],
            examples: [
                "four": .example(.init(value: .init(URL(string: "http://address.com")!)))
            ],
            requestBodies: [
                "five": .request(.init(content: [:]))
            ],
            headers: [
                "six": .header(.init(schema: .string))
            ],
            securitySchemes: [
                "seven": .securityScheme(.http(scheme: "cool"))
            ],
            links: [
                "eight": .link(.init(operationId: "op1"))
            ],
            callbacks: [
                "nine": .callbacks([
                    OpenAPI.CallbackURL(rawValue: "{$request.query.queryUrl}")!: .pathItem(
                        .init(
                            post: .init(
                                responses: [
                                    200: .response(
                                        description: "callback successfully processed"
                                    )
                                ]
                            )
                        )
                    )
                ])
            ],
            mediaTypes: [
                "ten": .content(.init(schema: .string))
            ],
            pathItems: [
                "eleven": .init(get: .init(responses: [200: .response(description: "response")]))
            ],
            vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
        )

        let c2 = OpenAPI.Components.direct(
            schemas: [
                "one": .string,
                "ref": .reference(.component(named: "one"))
            ],
            responses: [
                "two": .init(description: "hello", content: [:])
            ],
            parameters: [
                "three": .init(name: "hi", context: .query(content: [:]))
            ],
            examples: [
                "four": .init(value: .init(URL(string: "http://address.com")!))
            ],
            requestBodies: [
                "five": .init(content: [:])
            ],
            headers: [
                "six": .init(schema: .string)
            ],
            securitySchemes: [
                "seven": .http(scheme: "cool")
            ],
            links: [
                "eight": .init(operationId: "op1")
            ],
            callbacks: [
                "nine": [
                    OpenAPI.CallbackURL(rawValue: "{$request.query.queryUrl}")!: .pathItem(
                        .init(
                            post: .init(
                                responses: [
                                    200: .response(
                                        description: "callback successfully processed"
                                    )
                                ]
                            )
                        )
                    )
                ]
            ],
            mediaTypes: [
                "ten": .init(schema: .string)
            ],
            pathItems: [
                "eleven": .init(get: .init(responses: [200: .response(description: "response")]))
            ],
            vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
        )

        XCTAssertEqual(c1, c2)
    }

    func test_referenceLookup() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .string,
                "world": .integer(required: false),
                "ref": .reference(.component(named: "hello"))
            ],
            parameters: [
                "my_direct_param": .parameter(.cookie(name: "my_param", schema: .string)),
                "my_param": .reference(.component(named: "my_direct_param"))
            ]
        )

        let ref1 = JSONReference<JSONSchema>.component(named: "world")
        let ref2 = JSONReference<JSONSchema>.component(named: "missing")
        let ref3 = JSONReference<JSONSchema>.component(named: "ref")
        let ref4 = JSONReference<OpenAPI.Parameter>.component(named: "param")

        XCTAssertEqual(components[ref1], .integer(required: false))
        XCTAssertEqual(try? components.lookup(ref1), components[ref1])
        XCTAssertNil(components[ref2])
        XCTAssertEqual(components[ref3], .string)
        XCTAssertEqual(try? components.lookup(ref3), components[ref3])
        XCTAssertNil(components[ref4])

        let ref5 = JSONReference<JSONSchema>.InternalReference.component(name: "world")
        let ref6 = JSONReference<JSONSchema>.InternalReference.component(name: "missing")
        let ref7 = JSONReference<OpenAPI.Parameter>.InternalReference.component(name: "param")

        XCTAssertEqual(components[ref5], .integer(required: false))
        XCTAssertNil(components[ref6])
        XCTAssertNil(components[ref7])

        let ref8 = JSONReference<OpenAPI.Parameter>.component(named: "my_param")

        XCTAssertEqual(components[ref8], .cookie(name: "my_param", schema: .string))

        let ref9 = JSONReference<JSONSchema>.external(URL(string: "hello.json")!)

        XCTAssertNil(components[ref9])

        XCTAssertThrowsError(try components.contains(ref9))
    }

    func test_lookupOnce() throws {
        let components = OpenAPI.Components(
            parameters: [
                "my_direct_param": .parameter(.cookie(name: "my_param", schema: .string)),
                "my_param": .reference(.component(named: "my_direct_param"))
            ]
        )

        let ref1 = JSONReference<OpenAPI.Parameter>.component(named: "my_param")
        let ref2 = JSONReference<OpenAPI.Parameter>.component(named: "my_direct_param")

        XCTAssertEqual(try components.lookupOnce(ref1), .reference(.component(named: "my_direct_param")))
        XCTAssertEqual(try components.lookupOnce(ref2), .parameter(.cookie(name: "my_param", schema: .string)))
    }

    func test_failedExternalReferenceLookup() {
        let components = OpenAPI.Components.noComponents
        let ref = JSONReference<JSONSchema>.external(URL(string: "hi.json#/hello")!)

        XCTAssertThrowsError(try components.contains(ref)) { error in
            XCTAssertEqual(String(describing: error), "You cannot look up remote JSON references in the Components Object local to this file.")
        }
    }

    func test_referenceCreation() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .string,
                "world": .integer(required: false)
            ]
        )

        let ref1 = try components.reference(named: "hello", ofType: JSONSchema.self)
        let ref2 = try components.reference(named: "world", ofType: JSONSchema.self)
        XCTAssertEqual(ref1, .component(named: "hello"))
        XCTAssertEqual(ref2, .component(named: "world"))

        XCTAssertThrowsError(try components.reference(named: "missing", ofType: JSONSchema.self))
        XCTAssertThrowsError(try components.reference(named: "hello", ofType: OpenAPI.Parameter.self))
    }

    func test_failedReferenceCreation() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(try components.reference(named: "hello", ofType: JSONSchema.self)) { error in
            XCTAssertEqual(String(describing: error), "You cannot create references to components that do not exist in the Components Object this way. You can construct a `JSONReference` directly if you need to circumvent this protection. 'hello' was not found in schemas.")
        }
    }

    func test_lookupEachType() throws {
        let components = OpenAPI.Components.direct(
            schemas: [
                "one": .string
            ],
            responses: [
                "two": .init(description: "hello", content: [:])
            ],
            parameters: [
                "three": .init(name: "hello", context: .query(schema: .string))
            ],
            examples: [
                "four": .init(value: .init(URL(string: "hello.com/hello")!))
            ],
            requestBodies: [
                "five": .init(content: [:])
            ],
            headers: [
                "six": .init(schema: .string)
            ],
            securitySchemes: [
                "seven": .apiKey(name: "hello", location: .cookie)
            ],
            links: [
                "eight": .init(operationId: "op1")
            ],
            callbacks: [
                "nine": [
                    OpenAPI.CallbackURL(rawValue: "{$url}")!: .pathItem(.init(post: .init(responses: [:])))
                ]
            ],
            mediaTypes: [
                "ten": .init(schema: .string)
            ],
            pathItems: [
                "eleven": .init(get: .init(responses: [:]))
            ]
        )

        let ref1 = try components.reference(named: "one", ofType: JSONSchema.self)
        let ref2 = try components.reference(named: "two", ofType: OpenAPI.Response.self)
        let ref3 = try components.reference(named: "three", ofType: OpenAPI.Parameter.self)
        let ref4 = try components.reference(named: "four", ofType: OpenAPI.Example.self)
        let ref5 = try components.reference(named: "five", ofType: OpenAPI.Request.self)
        let ref6 = try components.reference(named: "six", ofType: OpenAPI.Header.self)
        let ref7 = try components.reference(named: "seven", ofType: OpenAPI.SecurityScheme.self)
        let ref8 = try components.reference(named: "eight", ofType: OpenAPI.Link.self)
        let ref9 = try components.reference(named: "nine", ofType: OpenAPI.Callbacks.self)
        let ref10 = try components.reference(named: "ten", ofType: OpenAPI.Content.self)
        let ref11 = try components.reference(named: "eleven", ofType: OpenAPI.PathItem.self)

        XCTAssertEqual(components[ref1], .string)
        XCTAssertEqual(components[ref2], .init(description: "hello", content: [:]))
        XCTAssertEqual(components[ref3], .init(name: "hello", context: .query(schema: .string)))
        XCTAssertEqual(components[ref4], .init(value: .init(URL(string: "hello.com/hello")!)))
        XCTAssertEqual(components[ref5], .init(content: [:]))
        XCTAssertEqual(components[ref6], .init(schema: .string))
        XCTAssertEqual(components[ref7], .apiKey(name: "hello", location: .cookie))
        XCTAssertEqual(components[ref8], .init(operationId: "op1"))
        XCTAssertEqual(
            components[ref9],
            [
                OpenAPI.CallbackURL(rawValue: "{$url}")!: .pathItem(.init(post: .init(responses: [:])))
            ]
        )
        XCTAssertEqual(components[ref10], .init(schema: .string))
        XCTAssertEqual(components[ref11], .init(get: .init(responses: [:])))
    }

    func test_subscriptLookup() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .boolean
            ]
        )

        let schemas: [Either<OpenAPI.Reference<JSONSchema>, JSONSchema>] = [
            .schema(.string),
            .reference(.component(named: "hello")),
            .reference(.component(named: "not_there"))
        ]

        let foundSchemas = schemas.map { components[$0] }

        XCTAssertEqual(foundSchemas, [.string, .boolean, nil])

        let schemas2 = schemas[0...1]

        let foundSchemas2 = try schemas2.map(components.lookup)

        XCTAssertEqual(foundSchemas2, [.string, .boolean])
    }

    func test_lookup() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .boolean
            ],
            links: [
                "linky": .link(.init(operationId: "op 1")),
                "linky_ref": .reference(.component(named: "linky")),
                "cycle_start": .reference(.component(named: "cycle_end")),
                "cycle_end": .reference(.component(named: "cycle_start"))
            ]
        )

        let schema1: Either<OpenAPI.Reference<JSONSchema>, JSONSchema> = .reference(.component(named: "hello"))

        let resolvedSchema = try components.lookup(schema1)

        XCTAssertEqual(resolvedSchema, .boolean)

        let schema2: Either<OpenAPI.Reference<JSONSchema>, JSONSchema> = .reference(.component(named: "not_there"))

        XCTAssertThrowsError(try components.lookup(schema2)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .missingOnLookup(name: "not_there", key: "schemas"))
            XCTAssertEqual((error as? OpenAPI.Components.ReferenceError)?.description, "Failed to look up a JSON Reference. 'not_there' was not found in schemas.")
        }

        let schema3: Either<OpenAPI.Reference<JSONSchema>, JSONSchema> = .reference(.external(URL(string: "https://hi.com/hi.json#/hello/world")!))

        XCTAssertThrowsError(try components.lookup(schema3)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .cannotLookupRemoteReference)
        }

        let link1: Either<OpenAPI.Reference<OpenAPI.Link>, OpenAPI.Link> = .reference(.component(named: "hello"))

        XCTAssertThrowsError(try components.lookup(link1)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .missingOnLookup(name: "hello", key: "links"))
            XCTAssertEqual((error as? OpenAPI.Components.ReferenceError)?.description, "Failed to look up a JSON Reference. 'hello' was not found in links.")
        }

        let link2: Either<OpenAPI.Reference<OpenAPI.Link>, OpenAPI.Link> = .reference(.component(named: "linky"))

        XCTAssertEqual(try components.lookup(link2), .init(operationId: "op 1"))

        let link3: Either<OpenAPI.Reference<OpenAPI.Link>, OpenAPI.Link> = .reference(.component(named: "linky_ref"))

        XCTAssertEqual(try components.lookup(link3), .init(operationId: "op 1"))

        let link4: Either<OpenAPI.Reference<OpenAPI.Link>, OpenAPI.Link> = .reference(.component(named: "cycle_start"))

        XCTAssertThrowsError(try components.lookup(link4)) { error in
            XCTAssertEqual((error as? OpenAPI.Components.ReferenceCycleError)?.description, "Encountered a JSON Schema $ref cycle that prevents fully resolving a reference at \'#/components/links/cycle_start\'. This type of reference cycle is not inherently problematic for JSON Schemas, but it does mean OpenAPIKit cannot fully resolve references because attempting to do so results in an infinite loop over any reference cycles. You should still be able to parse the document, just avoid requesting a `locallyDereferenced()` copy or fully looking up references in cycles. `lookupOnce()` is your best option in this case.")
        }

        let reference1: JSONReference<JSONSchema> = .component(named: "hello")

        let resolvedSchema2 = try components.lookup(reference1)

        XCTAssertEqual(resolvedSchema2, .boolean)

        let reference2: JSONReference<JSONSchema> = .component(named: "not_there")

        XCTAssertThrowsError(try components.lookup(reference2)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .missingOnLookup(name: "not_there", key: "schemas"))
        }

        let reference3: JSONReference<JSONSchema> = .external(URL(string: "https://hi.com/hi.json#/hello/world")!)

        XCTAssertThrowsError(try components.lookup(reference3)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .cannotLookupRemoteReference)
        }
    }

    func test_goodKeysNoProblems() {
        XCTAssertNil(OpenAPI.ComponentKey.problem(with: "hello"))
        XCTAssertNil(OpenAPI.ComponentKey.problem(with: "_hell.o-"))
        XCTAssertNil(OpenAPI.ComponentKey.problem(with: "HELLO"))
    }

    func test_badKeysHaveProblems() {
        XCTAssertEqual(OpenAPI.ComponentKey.problem(with: "#hello"), "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '#hello' does not..")
        XCTAssertEqual(OpenAPI.ComponentKey.problem(with: ""), "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '' does not..")
    }
}

// MARK: - Codable Tests
extension ComponentsTests {
    func test_minimal_encode() throws {
        let t1 = OpenAPI.Components()

        let encoded = try orderUnstableTestStringFromEncoding(of: t1)

        assertJSONEquivalent(
            encoded,
            """
            {

            }
            """
        )
    }

    func test_minimal_decode() throws {
        let t1 =
        """
        {

        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(OpenAPI.Components.self, from: t1)

        XCTAssertEqual(decoded, OpenAPI.Components())
    }

    func test_schemaReference_encode() throws {
        let t1 = OpenAPI.Components(
            schemas: [
                "ref": .reference(.external(URL(string: "./hi.yml")!))
            ]
        )

        let encoded = try orderUnstableTestStringFromEncoding(of: t1)

        assertJSONEquivalent(
            encoded,
            """
            {
              "schemas" : {
                "ref" : {
                  "$ref" : ".\\/hi.yml"
                }
              }
            }
            """
        )
    }

    func test_schemaReference_decode() throws {
        let t1 =
        """
        {
          "schemas" : {
            "ref" : {
              "$ref" : "./hi.yml"
            }
          }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(OpenAPI.Components.self, from: t1)

        XCTAssertEqual(decoded, OpenAPI.Components(
            schemas: [
                "ref": .reference(.external(URL(string: "./hi.yml")!))
            ]
        ))
    }

    func test_maximal_encode() throws {
        let t1 = OpenAPI.Components.direct(
            schemas: [
                "one": .string
            ],
            responses: [
                "two": .init(description: "hello", content: [:])
            ],
            parameters: [
                "three": .init(name: "hi", context: .query(content: [:]))
            ],
            examples: [
                "four": .init(value: .init(URL(string: "http://address.com")!))
            ],
            requestBodies: [
                "five": .init(content: [:])
            ],
            headers: [
                "six": .init(schema: .string)
            ],
            securitySchemes: [
                "seven": .http(scheme: "cool")
            ],
            links: [
                "eight": .init(operationId: "op1")
            ],
            callbacks: [
                "nine": [
                    OpenAPI.CallbackURL(rawValue: "{$request.query.queryUrl}")!: .pathItem(
                        .init(
                            post: .init(
                                responses: [
                                    200: .response(
                                        description: "callback successfully processed"
                                    )
                                ]
                            )
                        )
                    )
                ]
            ],
            mediaTypes: [
                "ten": .init(schema: .string)
            ],
            pathItems: [
                "eleven": .init(get: .init(responses: [200: .response(description: "response")]))
            ],
            vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
        )

        let encoded = try orderUnstableTestStringFromEncoding(of: t1)

        assertJSONEquivalent(
            encoded,
            """
            {
              "callbacks" : {
                "nine" : {
                  "{$request.query.queryUrl}" : {
                    "post" : {
                      "responses" : {
                        "200" : {
                          "description" : "callback successfully processed"
                        }
                      }
                    }
                  }
                }
              },
              "examples" : {
                "four" : {
                  "externalValue" : "http:\\/\\/address.com"
                }
              },
              "headers" : {
                "six" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "links" : {
                "eight" : {
                  "operationId" : "op1"
                }
              },
              "mediaTypes" : {
                "ten" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "parameters" : {
                "three" : {
                  "content" : {

                  },
                  "in" : "query",
                  "name" : "hi"
                }
              },
              "pathItems" : {
                "eleven" : {
                  "get" : {
                    "responses" : {
                      "200" : {
                        "description" : "response"
                      }
                    }
                  }
                }
              },
              "requestBodies" : {
                "five" : {
                  "content" : {

                  }
                }
              },
              "responses" : {
                "two" : {
                  "description" : "hello"
                }
              },
              "schemas" : {
                "one" : {
                  "type" : "string"
                }
              },
              "securitySchemes" : {
                "seven" : {
                  "scheme" : "cool",
                  "type" : "http"
                }
              },
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_maximal_decode() throws {
        let t1 =
        """
        {
          "callbacks" : {
            "nine" : {
              "{$request.query.queryUrl}" : {
                "post" : {
                  "responses" : {
                    "200" : {
                      "description" : "callback successfully processed"
                    }
                  }
                }
              }
            }
          },
          "examples" : {
            "four" : {
              "externalValue" : "http:\\/\\/address.com"
            }
          },
          "headers" : {
            "six" : {
              "schema" : {
                "type" : "string"
              }
            }
          },
          "links" : {
            "eight" : {
              "operationId" : "op1"
            }
          },
          "mediaTypes" : {
            "ten" : {
              "schema" : {
                "type" : "string"
              }
            }
          },
          "parameters" : {
            "three" : {
              "content" : {

              },
              "in" : "query",
              "name" : "hi"
            }
          },
          "pathItems" : {
            "eleven" : {
              "get" : {
                "responses" : {
                  "200" : {
                    "description" : "response"
                  }
                }
              }
            }
          },
          "requestBodies" : {
            "five" : {
              "content" : {

              }
            }
          },
          "responses" : {
            "two" : {
              "description" : "hello"
            }
          },
          "schemas" : {
            "one" : {
              "type" : "string"
            }
          },
          "securitySchemes" : {
            "seven" : {
              "scheme" : "cool",
              "type" : "http"
            }
          },
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(OpenAPI.Components.self, from: t1)

        XCTAssertEqual(
            decoded,
            OpenAPI.Components.direct(
                schemas: [
                    "one": .string
                ],
                responses: [
                    "two": .init(description: "hello", content: [:])
                ],
                parameters: [
                    "three": .init(name: "hi", context: .query(content: [:]))
                ],
                examples: [
                    "four": .init(value: .init(URL(string: "http://address.com")!))
                ],
                requestBodies: [
                    "five": .init(content: [:])
                ],
                headers: [
                    "six": .init(schema: .string)
                ],
                securitySchemes: [
                    "seven": .http(scheme: "cool")
                ],
                links: [
                    "eight": .init(operationId: "op1")
                ],
                callbacks: [
                    "nine": [
                        OpenAPI.CallbackURL(rawValue: "{$request.query.queryUrl}")!: .pathItem(
                            .init(
                                post: .init(
                                    responses: [
                                        200: .response(
                                            description: "callback successfully processed"
                                        )
                                    ]
                                )
                            )
                        )
                    ]
                ],
                mediaTypes: [
                    "ten": .init(schema: .string)
                ],
                pathItems: [
                    "eleven": .init(get: .init(responses: [200: .response(description: "response")]))
                ],
                vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
            )
        )
    }

    func test_doesNotFailDecodingLinks() {
        let t1 = """
        {
          "links" : {
            "link" : {
              "operationId" : "test",
              "parameters" : {
                "userId" : "$response.body#/id",
                "description" : "A link test"
              }
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertNoThrow(try orderUnstableDecode(OpenAPI.Components.self, from: t1))
    }
}

// MARK: PathItems

extension ComponentsTests {
  
  func test_pathItems_encode() throws {
      let op = OpenAPI.Operation(responses: [:])
      let t1 = OpenAPI.Components(
        pathItems: [
          "path-test" : .init(
            get: op,
            put: op,
            post: op,
            delete: op,
            options: op,
            head: op,
            patch: op,
            trace: op,
            query: op
          )
        ]
      )

      let encoded = try orderUnstableTestStringFromEncoding(of: t1)

      assertJSONEquivalent(
          encoded,
          """
          {
            "pathItems" : {
              "path-test" : {
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
      )
  }

  func test_pathItems_decode() throws {
      let t1 =
      """
          {
            "pathItems" : {
              "path-test" : {
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
                }
              }
            }
          }
      """.data(using: .utf8)!

      let decoded = try orderUnstableDecode(OpenAPI.Components.self, from: t1)
      let op = OpenAPI.Operation(responses: [:])

      XCTAssertEqual(
          decoded,
          OpenAPI.Components(
                  pathItems: [
                    "path-test" : .init(
                      get: op,
                      put: op,
                      post: op,
                      delete: op,
                      options: op,
                      head: op,
                      patch: op,
                      trace: op,
                      query: op
                    )
                  ]
                )
      )
  }
  
}

// MARK: ComponentKey
extension ComponentsTests {
    func test_acceptableKeys_encode() throws {
        let t1 = ComponentKeyWrapper(key: "shell0")
        let t2 = ComponentKeyWrapper(key: "hello_world1234-.")

        let encoded1 = try orderUnstableTestStringFromEncoding(of: t1)
        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded1,
            """
            {
              "key" : "shell0"
            }
            """
        )

        assertJSONEquivalent(
            encoded2,
            """
            {
              "key" : "hello_world1234-."
            }
            """
        )
    }

    func test_acceptableKeys_decode() throws {
        let t1 =
        """
        {
            "key": "shell0"
        }
        """.data(using: .utf8)!

        let t2 =
        """
        {
            "key": "1234-_."
        }
        """.data(using: .utf8)!

        let decoded1 = try orderUnstableDecode(ComponentKeyWrapper.self, from: t1)
        let decoded2 = try orderUnstableDecode(ComponentKeyWrapper.self, from: t2)

        XCTAssertEqual(decoded1.key, "shell0")
        XCTAssertEqual(decoded2.key, "1234-_.")
    }

    func test_unacceptableKeys_encode() {
        let t1 = ComponentKeyWrapper(key: "$hell0")
        let t2 = ComponentKeyWrapper(key: "hello world")

        XCTAssertThrowsError(try orderUnstableEncode(t1))
        XCTAssertThrowsError(try orderUnstableEncode(t2))
    }

    func test_unacceptableKeys_decode() {
        let t1 =
        """
        {
            "key": "$hell0"
        }
        """.data(using: .utf8)!

        let t2 =
        """
        {
            "key": "hello world"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(ComponentKeyWrapper.self, from: t1))
        XCTAssertThrowsError(try orderUnstableDecode(ComponentKeyWrapper.self, from: t2))
    }
}

fileprivate struct ComponentKeyWrapper: Codable {
    let key: OpenAPI.ComponentKey
}

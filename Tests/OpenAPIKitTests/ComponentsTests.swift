//
//  ComponentsTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ComponentsTests: XCTestCase {
    func test_referenceLookup() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .string,
                "world": .integer(required: false)
            ]
        )

        let ref1 = JSONReference<JSONSchema>.component(named: "world")
        let ref2 = JSONReference<JSONSchema>.component(named: "missing")
        let ref3 = JSONReference<OpenAPI.Parameter>.component(named: "param")

        XCTAssertEqual(components[ref1], .integer(required: false))
        XCTAssertEqual(components.dereference(ref1), components[ref1])
        XCTAssertNil(components[ref2])
        XCTAssertNil(components[ref3])

        let ref4 = JSONReference<JSONSchema>.InternalReference.component(name: "world")
        let ref5 = JSONReference<JSONSchema>.InternalReference.component(name: "missing")
        let ref6 = JSONReference<OpenAPI.Parameter>.InternalReference.component(name: "param")

        XCTAssertEqual(components[ref4], .integer(required: false))
        XCTAssertNil(components[ref5])
        XCTAssertNil(components[ref6])

        let ref7 = JSONReference<JSONSchema>.external(URL(string: "hello.json")!)

        XCTAssertNil(components[ref7])

        XCTAssertThrowsError(try components.contains(ref7))
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
        let components = OpenAPI.Components(
            schemas: [
                "one": .string
            ],
            responses: [
                "two": .init(description: "hello", content: [:])
            ],
            parameters: [
                "three": .init(name: "hello", context: .query, schema: .string)
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
            ]
        )

        let ref1 = try components.reference(named: "one", ofType: JSONSchema.self)
        let ref2 = try components.reference(named: "two", ofType: OpenAPI.Response.self)
        let ref3 = try components.reference(named: "three", ofType: OpenAPI.Parameter.self)
        let ref4 = try components.reference(named: "four", ofType: OpenAPI.Example.self)
        let ref5 = try components.reference(named: "five", ofType: OpenAPI.Request.self)
        let ref6 = try components.reference(named: "six", ofType: OpenAPI.Header.self)
        let ref7 = try components.reference(named: "seven", ofType: OpenAPI.SecurityScheme.self)

        XCTAssertEqual(components[ref1], .string)
        XCTAssertEqual(components[ref2], .init(description: "hello", content: [:]))
        XCTAssertEqual(components[ref3], .init(name: "hello", context: .query, schema: .string))
        XCTAssertEqual(components[ref4], .init(value: .init(URL(string: "hello.com/hello")!)))
        XCTAssertEqual(components[ref5], .init(content: [:]))
        XCTAssertEqual(components[ref6], .init(schema: .string))
        XCTAssertEqual(components[ref7], .apiKey(name: "hello", location: .cookie))
    }

    func test_dereference() {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .boolean
            ]
        )

        let schemas: [Either<JSONReference<JSONSchema>, JSONSchema>] = [
            .schema(.string),
            .reference(.component(named: "hello")),
            .reference(.component(named: "not_there"))
        ]

        let resolvedSchemas = schemas.map(components.dereference)

        XCTAssertEqual(resolvedSchemas, [.string, .boolean, nil])
    }

    func test_forceDereference() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .boolean
            ]
        )

        let schema1: Either<JSONReference<JSONSchema>, JSONSchema> = .reference(.component(named: "hello"))

        let resolvedSchema = try components.forceDereference(schema1)

        XCTAssertEqual(resolvedSchema, .boolean)

        let schema2: Either<JSONReference<JSONSchema>, JSONSchema> = .reference(.component(named: "not_there"))

        XCTAssertThrowsError(try components.forceDereference(schema2)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.MissingReferenceError, .referenceMissingOnLookup(name: "not_there", key: "schemas"))
            XCTAssertEqual((error as? OpenAPI.Components.MissingReferenceError)?.description, "Failed to look up a JSON Reference. 'not_there' was not found in schemas.")
        }

        let schema3: Either<JSONReference<JSONSchema>, JSONSchema> = .reference(.external(URL(string: "https://hi.com/hi.json#/hello/world")!))

        XCTAssertThrowsError(try components.forceDereference(schema3)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .cannotLookupRemoteReference)
        }

        let reference1: JSONReference<JSONSchema> = .component(named: "hello")

        let resolvedSchema2 = try components.forceDereference(reference1)

        XCTAssertEqual(resolvedSchema2, .boolean)

        let reference2: JSONReference<JSONSchema> = .component(named: "not_there")

        XCTAssertThrowsError(try components.forceDereference(reference2)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.MissingReferenceError, .referenceMissingOnLookup(name: "not_there", key: "schemas"))
        }

        let reference3: JSONReference<JSONSchema> = .external(URL(string: "https://hi.com/hi.json#/hello/world")!)

        XCTAssertThrowsError(try components.forceDereference(reference3)) { error in
            XCTAssertEqual(error as? OpenAPI.Components.ReferenceError, .cannotLookupRemoteReference)
        }
    }
}

// MARK: - Codable Tests
extension ComponentsTests {
    func test_minimal_encode() throws {
        let t1 = OpenAPI.Components()

        let encoded = try testStringFromEncoding(of: t1)

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

        let decoded = try testDecoder.decode(OpenAPI.Components.self, from: t1)

        XCTAssertEqual(decoded, OpenAPI.Components())
    }

    func test_maximal_encode() throws {
        let t1 = OpenAPI.Components(
            schemas: [
                "one": .string
            ],
            responses: [
                "two": .init(description: "hello", content: [:])
            ],
            parameters: [
                "three": .init(name: "hi", context: .query, content: [:])
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
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )

        let encoded = try testStringFromEncoding(of: t1)

        assertJSONEquivalent(
            encoded,
"""
{
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
  "parameters" : {
    "three" : {
      "content" : {

      },
      "in" : "query",
      "name" : "hi"
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
  "parameters" : {
    "three" : {
      "content" : {

      },
      "in" : "query",
      "name" : "hi"
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

        let decoded = try testDecoder.decode(OpenAPI.Components.self, from: t1)

        XCTAssertEqual(
            decoded,
            OpenAPI.Components(
                schemas: [
                    "one": .string(required: false)
                ],
                responses: [
                    "two": .init(description: "hello", content: [:])
                ],
                parameters: [
                    "three": .init(name: "hi", context: .query, content: [:])
                ],
                examples: [
                    "four": .init(value: .init(URL(string: "http://address.com")!))
                ],
                requestBodies: [
                    "five": .init(content: [:])
                ],
                headers: [
                    "six": .init(schema: .string(required: false))
                ],
                securitySchemes: [
                    "seven": .http(scheme: "cool")
                ],
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
            )
        )
    }
}

// MARK: ComponentKey
extension ComponentsTests {
    func test_acceptableKeys_encode() throws {
        let t1 = ComponentKeyWrapper(key: "shell0")
        let t2 = ComponentKeyWrapper(key: "hello_world1234-.")

        let encoded1 = try testStringFromEncoding(of: t1)
        let encoded2 = try testStringFromEncoding(of: t2)

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

        let decoded1 = try testDecoder.decode(ComponentKeyWrapper.self, from: t1)
        let decoded2 = try testDecoder.decode(ComponentKeyWrapper.self, from: t2)

        XCTAssertEqual(decoded1.key, "shell0")
        XCTAssertEqual(decoded2.key, "1234-_.")
    }

    func test_unacceptableKeys_encode() {
        let t1 = ComponentKeyWrapper(key: "$hell0")
        let t2 = ComponentKeyWrapper(key: "hello world")

        XCTAssertThrowsError(try testEncoder.encode(t1))
        XCTAssertThrowsError(try testEncoder.encode(t2))
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

        XCTAssertThrowsError(try testDecoder.decode(ComponentKeyWrapper.self, from: t1))
        XCTAssertThrowsError(try testDecoder.decode(ComponentKeyWrapper.self, from: t2))
    }
}

fileprivate struct ComponentKeyWrapper: Codable {
    let key: OpenAPI.ComponentKey
}

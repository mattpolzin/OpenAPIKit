//
//  ParameterSchemaTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ParameterSchemaTests: XCTestCase {
    typealias Schema = OpenAPI.Parameter.SchemaContext

    func test_initialize() {
        // init specifying opposite of default explode and allowReserved.
        let t1 = Schema(
            .string,
            style: .form,
            explode: false,
            allowReserved: true,
            example: "hello"
        )

        XCTAssertEqual(t1.schema, .b(.string))
        XCTAssertEqual(t1.style, .form)
        XCTAssertFalse(t1.explode)
        XCTAssertTrue(t1.allowReserved)
        XCTAssertEqual(t1.example?.value as? String, "hello")
        XCTAssertNil(t1.examples)

        // init with defaults
        let t2 = Schema(
            .string,
            style: .form
        )

        XCTAssertEqual(t2.schema, .b(.string))
        XCTAssertEqual(t2.style, .form)
        XCTAssertTrue(t2.explode)
        XCTAssertFalse(t2.allowReserved)
        XCTAssertNil(t2.example)
        XCTAssertNil(t2.examples)

        // schema reference override explode
        let t3 = Schema(
            schemaReference: .external(URL(string: "hello.yml")!),
            style: .deepObject,
            explode: true
        )

        XCTAssertEqual(t3.schema, .a(.external(URL(string: "hello.yml")!)))
        XCTAssertEqual(t3.style, .deepObject)
        XCTAssertTrue(t3.explode)
        XCTAssertFalse(t3.allowReserved)
        XCTAssertNil(t3.example)
        XCTAssertNil(t3.examples)

        // schema reference default explode
        let t4 = Schema(
            schemaReference: .external(URL(string: "hello.yml")!),
            style: .deepObject
        )

        XCTAssertEqual(t4.schema, .a(.external(URL(string: "hello.yml")!)))
        XCTAssertEqual(t4.style, .deepObject)
        XCTAssertFalse(t4.explode)
        XCTAssertFalse(t4.allowReserved)
        XCTAssertNil(t4.example)
        XCTAssertNil(t4.examples)

        // straight to schema override explode
        let t5 = Schema(
            .string,
            style: .deepObject,
            explode: true
        )

        XCTAssertEqual(t5.schema, .b(.string))
        XCTAssertEqual(t5.style, .deepObject)
        XCTAssertTrue(t5.explode)
        XCTAssertFalse(t5.allowReserved)
        XCTAssertNil(t5.example)
        XCTAssertNil(t5.examples)

        // straight to schema default explode
        let t6 = Schema(
            .string,
            style: .deepObject
        )

        XCTAssertEqual(t6.schema, .b(.string))
        XCTAssertEqual(t6.style, .deepObject)
        XCTAssertFalse(t6.explode)
        XCTAssertFalse(t6.allowReserved)
        XCTAssertNil(t6.example)
        XCTAssertNil(t6.examples)

        // straight to schema multiple examples
        let t7 = Schema(
            .string,
            style: .deepObject,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .example(value: .init("world"))
            ]
        )

        XCTAssertEqual(t7.schema, .b(.string))
        XCTAssertEqual(t7.style, .deepObject)
        XCTAssertFalse(t7.explode)
        XCTAssertFalse(t7.allowReserved)
        XCTAssertNotNil(t7.example)
        XCTAssertEqual(t7.example?.value as? String, "hello")
        XCTAssertNotNil(t7.examples)
        XCTAssertEqual(t7.examples?["two"]?.exampleValue?.value.codableValue?.value as? String, "world")

        // straight to schema override explode multiple examples
        let t8 = Schema(
            .string,
            style: .deepObject,
            explode: true,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .example(value: .init("world"))
            ]
        )

        XCTAssertEqual(t8.schema, .b(.string))
        XCTAssertEqual(t8.style, .deepObject)
        XCTAssertTrue(t8.explode)
        XCTAssertFalse(t8.allowReserved)
        XCTAssertNotNil(t8.example)
        XCTAssertEqual(t8.example?.value as? String, "hello")
        XCTAssertNotNil(t8.examples)
        XCTAssertEqual(t8.examples?["two"]?.exampleValue?.value.codableValue?.value as? String, "world")

        // schema reference multiple examples
        let t9 = Schema(
            schemaReference: .external(URL(string: "hello.yml")!),
            style: .deepObject,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .reference(.external(URL(string: "world.yml")!))
            ]
        )

        XCTAssertEqual(t9.schema, .a(.external(URL(string: "hello.yml")!)))
        XCTAssertEqual(t9.style, .deepObject)
        XCTAssertFalse(t9.explode)
        XCTAssertFalse(t9.allowReserved)
        XCTAssertNotNil(t9.example)
        XCTAssertEqual(t9.example?.value as? String, "hello")
        XCTAssertNotNil(t9.examples)
        XCTAssertEqual(t9.examples?["two"]?.reference, .external(URL(string: "world.yml")!))

        // schema reference override explode multiple examples
        let t10 = Schema(
            schemaReference: .external(URL(string: "hello.yml")!),
            style: .deepObject,
            explode: true,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .reference(.external(URL(string: "world.yml")!))
            ]
        )

        XCTAssertEqual(t10.schema, .a(.external(URL(string: "hello.yml")!)))
        XCTAssertEqual(t10.style, .deepObject)
        XCTAssertTrue(t10.explode)
        XCTAssertFalse(t10.allowReserved)
        XCTAssertNotNil(t10.example)
        XCTAssertEqual(t10.example?.value as? String, "hello")
        XCTAssertNotNil(t10.examples)
        XCTAssertEqual(t10.examples?["two"]?.reference, .external(URL(string: "world.yml")!))
    }

    public func test_style_defaults() {
        let t1 = Schema.Style.default(for: .query)
        XCTAssertEqual(t1, .form)

        let t2 = Schema.Style.default(for: .cookie)
        XCTAssertEqual(t2, .form)

        let t3 = Schema.Style.default(for: .path)
        XCTAssertEqual(t3, .simple)

        let t4 = Schema.Style.default(for: .header)
        XCTAssertEqual(t4, .simple)
    }

    public func test_style_defaultExplodes() {
        let t1 = Schema(.string, style: .form)
        XCTAssertTrue(t1.explode)

        let t2 = Schema(.string, style: .simple)
        XCTAssertFalse(t2.explode)

        let t3 = Schema(.string, style: .matrix)
        XCTAssertFalse(t3.explode)

        let t4 = Schema(.string, style: .label)
        XCTAssertFalse(t4.explode)

        let t5 = Schema(.string, style: .spaceDelimited)
        XCTAssertFalse(t5.explode)

        let t6 = Schema(.string, style: .pipeDelimited)
        XCTAssertFalse(t6.explode)

        let t7 = Schema(.string, style: .deepObject)
        XCTAssertFalse(t7.explode)
    }
}

// MARK: - Codable Tests
extension ParameterSchemaTests {
    func test_allDefaultsNoExamples_encode() throws {
        let schema = Schema(
            .string,
            style: .default(for: .path)
        )

        let encodedSchema = try orderUnstableTestStringFromEncoding(of: SchemaWrapper(location: .path, schema: schema))

        assertJSONEquivalent(
            encodedSchema,
"""
{
  "location" : "path",
  "schema" : {
    "schema" : {
      "type" : "string"
    }
  }
}
"""
        )
    }

    func test_allDefaultsNoExamples_decode() throws {
        let schemaData =
"""
{
  "location" : "path",
  "schema" : {
    "schema" : {
      "type" : "string"
    }
  }
}
""".data(using: .utf8)!

        let schema = try orderUnstableDecode(SchemaWrapper.self, from: schemaData).schema

        XCTAssertEqual(
            schema,
            Schema(
                .string,
                style: .default(for: .path)
            )
        )
    }

    func test_allDefaultsOneExample_encode() throws {
        let schema = Schema(
            .string,
            style: .default(for: .path),
            example: "hello"
        )

        let encodedSchema = try orderUnstableTestStringFromEncoding(of: SchemaWrapper(location: .path, schema: schema))

        assertJSONEquivalent(
            encodedSchema,
"""
{
  "location" : "path",
  "schema" : {
    "example" : "hello",
    "schema" : {
      "type" : "string"
    }
  }
}
"""
        )
    }

    func test_allDefaultsOneExample_decode() throws {
        let schemaData =
"""
{
  "location" : "path",
  "schema" : {
    "example" : "hello",
    "schema" : {
      "type" : "string"
    }
  }
}
""".data(using: .utf8)!

        let schema = try orderUnstableDecode(SchemaWrapper.self, from: schemaData).schema

        XCTAssertEqual(
            schema,
            Schema(
                .string,
                style: .default(for: .path),
                example: "hello"
            )
        )
    }

    func test_allDefaultsExamples_encode() throws {
        let schema = Schema(
            .string,
            style: .default(for: .path),
            examples: [
                "one": .example(value: .init("hello"))
            ]
        )

        let encodedSchema = try orderUnstableTestStringFromEncoding(of: SchemaWrapper(location: .path, schema: schema))

        assertJSONEquivalent(
            encodedSchema,
"""
{
  "location" : "path",
  "schema" : {
    "examples" : {
      "one" : {
        "value" : "hello"
      }
    },
    "schema" : {
      "type" : "string"
    }
  }
}
"""
        )
    }

    func test_allDefaultsExamples_decode() throws {
        let schemaData =
"""
{
  "location" : "path",
  "schema" : {
    "examples" : {
      "one" : {
        "value" : "hello"
      }
    },
    "schema" : {
      "type" : "string"
    }
  }
}
""".data(using: .utf8)!

        let schema = try orderUnstableDecode(SchemaWrapper.self, from: schemaData).schema

        XCTAssertEqual(
            schema,
            Schema(
                .string,
                style: .default(for: .path),
                examples: [
                    "one": .example(value: .init("hello"))
                ]
            )
        )
    }

    func test_styleOverride_encode() throws {
        let schema = Schema(
            .string,
            style: .form
        )

        let encodedSchema = try orderUnstableTestStringFromEncoding(of: SchemaWrapper(location: .path, schema: schema))

        assertJSONEquivalent(
            encodedSchema,
"""
{
  "location" : "path",
  "schema" : {
    "schema" : {
      "type" : "string"
    },
    "style" : "form"
  }
}
"""
        )
    }

    func test_styleOverride_decode() throws {
        let schemaData =
"""
{
  "location" : "path",
  "schema" : {
    "schema" : {
      "type" : "string"
    },
    "style" : "form"
  }
}
""".data(using: .utf8)!

        let schema = try orderUnstableDecode(SchemaWrapper.self, from: schemaData).schema

        XCTAssertEqual(
            schema,
            Schema(
                .string,
                style: .form
            )
        )
    }

    func test_explodeOverride_encode() throws {
        let schema = Schema(
            .string,
            style: .default(for: .path),
            explode: true
        )

        let encodedSchema = try orderUnstableTestStringFromEncoding(of: SchemaWrapper(location: .path, schema: schema))

        assertJSONEquivalent(
            encodedSchema,
"""
{
  "location" : "path",
  "schema" : {
    "explode" : true,
    "schema" : {
      "type" : "string"
    }
  }
}
"""
        )
    }

    func test_explodeOverride_decode() throws {
        let schemaData =
"""
{
  "location" : "path",
  "schema" : {
    "explode" : true,
    "schema" : {
      "type" : "string"
    }
  }
}
""".data(using: .utf8)!

        let schema = try orderUnstableDecode(SchemaWrapper.self, from: schemaData).schema

        XCTAssertEqual(
            schema,
            Schema(
                .string,
                style: .default(for: .path),
                explode: true
            )
        )
    }

    func test_allowReservedOverride_encode() throws {
        let schema = Schema(
            .string,
            style: .default(for: .path),
            allowReserved: true
        )

        let encodedSchema = try orderUnstableTestStringFromEncoding(of: SchemaWrapper(location: .path, schema: schema))

        assertJSONEquivalent(
            encodedSchema,
"""
{
  "location" : "path",
  "schema" : {
    "allowReserved" : true,
    "schema" : {
      "type" : "string"
    }
  }
}
"""
        )
    }

    func test_allowReservedOverride_decode() throws {
        let schemaData =
"""
{
  "location" : "path",
  "schema" : {
    "allowReserved" : true,
    "schema" : {
      "type" : "string"
    }
  }
}
""".data(using: .utf8)!

        let schema = try orderUnstableDecode(SchemaWrapper.self, from: schemaData).schema

        XCTAssertEqual(
            schema,
            Schema(
                .string,
                style: .default(for: .path),
                allowReserved: true
            )
        )
    }
}

fileprivate struct SchemaWrapper: Codable {
    let location: TestLocation
    let schema: OpenAPI.Parameter.SchemaContext

    init(location: OpenAPI.Parameter.Context, schema: OpenAPI.Parameter.SchemaContext) {
        self.location = .init(location)
        self.schema = schema
    }

    enum CodingKeys: String, CodingKey {
        case location
        case schema
    }

    enum TestLocation: String, Codable {
        case query
        case header
        case path
        case cookie

        var paramLoc: OpenAPI.Parameter.Context {
            switch self {
            case .query: return .query
            case .header: return .header
            case .path: return .path
            case .cookie: return .cookie
            }
        }

        init(_ paramLoc: OpenAPI.Parameter.Context) {
            switch paramLoc {
            case .query: self = .query
            case .header: self = .header
            case .path: self = .path
            case .cookie: self = .cookie
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(location, forKey: .location)

        try schema.encode(to: container.superEncoder(forKey: .schema), for: location.paramLoc)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let location = try container.decode(TestLocation.self, forKey: .location)
        self.location = location

        schema = try OpenAPI.Parameter.SchemaContext(from: container.superDecoder(forKey: .schema), for: location.paramLoc)
    }
}

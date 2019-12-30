//
//  VendorExtendableTests.swift
//  
//
//  Created by Mathew Polzin on 11/3/19.
//

import XCTest
@testable import OpenAPIKit

final class VendorExtendableTests: XCTestCase {
    func test_decode() throws {
        let data =
"""
{
    "x-tension": "hello",
    "x-two": [ "cool", "beans" ],
    "x-three": {
        "nested": 10
    },
    "one": "world",
    "two": "!"
}
""".data(using: .utf8)!

        let test = try JSONDecoder().decode(TestStruct.self, from: data)
        XCTAssertEqual(test.vendorExtensions.count, 3)

        XCTAssertEqual(test.vendorExtensions["x-tension"]?.value as? String, "hello")

        XCTAssert((test.vendorExtensions["x-two"]?.value as? [String])!.contains("cool"))
        XCTAssert((test.vendorExtensions["x-two"]?.value as? [String])!.contains("beans"))
        XCTAssertEqual((test.vendorExtensions["x-two"]?.value as? [String])?.count, 2)

        XCTAssertEqual((test.vendorExtensions["x-three"]?.value as? [String: Int])?.count, 1)
        XCTAssertEqual((test.vendorExtensions["x-three"]?.value as? [String: Int])?["nested"], 10)
    }

    func test_encodeSuccess() throws {
        let test = TestStruct(vendorExtensions: [
            "x-tension": "hello",
            "x-two": [
                "cool",
                "beans"
            ],
            "x-three": [
                "nested": 10
            ]
        ])

        let _ = try JSONEncoder().encode(test)
    }

    func test_arrayDecodeFailure() {
        let data =
"""
[
    "cool",
    "beans"
]
""".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(TestStruct.self, from: data)) { error in
            XCTAssert(error as? VendorExtensionDecodingError == VendorExtensionDecodingError.selfIsArrayNotDict)
        }
    }

    func test_nonXPrefixDecodeFailure() {
        let data =
"""
{
    "x-tension": "hello",
    "invalid": "world"
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(TestStruct.self, from: data)) { error in
            XCTAssert(error as? VendorExtensionDecodingError == VendorExtensionDecodingError.foundExtensionsWithoutXPrefix)
        }
    }
}

extension VendorExtendableTests {
    func test_encode() throws {
        let test = TestStruct(vendorExtensions: [
            "x-tension": "hello",
            "x-two": [
                "cool",
                "beans"
            ],
            "x-three": [
                "nested": 10
            ]
        ])

        let encoded = try testStringFromEncoding(of: test)

        XCTAssertEqual(encoded,
"""
{
  "one" : "world",
  "two" : "!",
  "x-tension" : "hello",
  "x-three" : {
    "nested" : 10
  },
  "x-two" : [
    "cool",
    "beans"
  ]
}
"""
        )
    }
}

private struct TestStruct: Codable, VendorExtendable {
    enum CodingKeys: ExtendableCodingKey {
        case one
        case two
        case other(String)

        static let allBuiltinKeys: [Self] = [.one, .two]

        static func extendedKey(for value: String) -> Self {
            return .other(value)
        }

        var stringValue: String {
            switch self {
            case .one: return "one"
            case .two: return "two"
            case .other(let val): return val
            }
        }

        init?(stringValue: String) {
            switch stringValue {
            case "one": self = .one
            case "two": self = .two
            default: return nil
            }
        }

        var intValue: Int? { return nil }

        init?(intValue: Int) {
            return nil
        }
    }

    public let vendorExtensions: Self.VendorExtensions

    init(vendorExtensions: Self.VendorExtensions) {
        self.vendorExtensions = vendorExtensions
    }

    public init(from decoder: Decoder) throws {
        vendorExtensions = try Self.extensions(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("world", forKey: .one)
        try container.encode("!", forKey: .two)
        try encodeExtensions(to: &container)
    }
}

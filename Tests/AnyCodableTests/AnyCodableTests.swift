@testable import OpenAPIKitCore
import XCTest

class AnyCodableTests: XCTestCase {
    func testInit() throws {
        let _ = AnyCodable("hi")
        let _: AnyCodable = nil
        let _: AnyCodable = true
        let _: AnyCodable = 10
        let _: AnyCodable = 3.4
        let _: AnyCodable = "hello"
        let _: AnyCodable = ["hi", "there"]
        let _: AnyCodable = ["hi": "there"]
    }

    func testEquality() throws {
        XCTAssertEqual(AnyCodable(()), AnyCodable(()))
        XCTAssertEqual(AnyCodable(true), AnyCodable(true))
        XCTAssertEqual(AnyCodable(2), AnyCodable(2))
        XCTAssertEqual(AnyCodable(Int8(2)), AnyCodable(Int8(2)))
        XCTAssertEqual(AnyCodable(Int16(2)), AnyCodable(Int16(2)))
        XCTAssertEqual(AnyCodable(Int32(2)), AnyCodable(Int32(2)))
        XCTAssertEqual(AnyCodable(Int64(2)), AnyCodable(Int64(2)))
        XCTAssertEqual(AnyCodable(UInt(2)), AnyCodable(UInt(2)))
        XCTAssertEqual(AnyCodable(UInt8(2)), AnyCodable(UInt8(2)))
        XCTAssertEqual(AnyCodable(UInt16(2)), AnyCodable(UInt16(2)))
        XCTAssertEqual(AnyCodable(UInt32(2)), AnyCodable(UInt32(2)))
        XCTAssertEqual(AnyCodable(UInt64(2)), AnyCodable(UInt64(2)))
        XCTAssertEqual(AnyCodable(Float(2)), AnyCodable(Float(2)))
        XCTAssertEqual(AnyCodable(Double(2)), AnyCodable(Double(2)))
        XCTAssertEqual(AnyCodable("hi"), AnyCodable("hi"))
        XCTAssertEqual(AnyCodable(URL(string: "file://./params/name.json")), AnyCodable(URL(string: "file://./params/name.json")))
        XCTAssertEqual(AnyCodable(["hi": AnyCodable(2)]), AnyCodable(["hi": AnyCodable(2)]))
        XCTAssertEqual(AnyCodable([AnyCodable("hi"), AnyCodable("there")]), AnyCodable([AnyCodable("hi"), AnyCodable("there")]))
        XCTAssertEqual(AnyCodable(["hi":1]), AnyCodable(["hi":1]))
        XCTAssertEqual(AnyCodable(["hi":1.2]), AnyCodable(["hi":1.2]))
        XCTAssertEqual(AnyCodable(["hi"]), AnyCodable(["hi"]))
        XCTAssertEqual(AnyCodable([1]), AnyCodable([1]))
        XCTAssertEqual(AnyCodable([1.2]), AnyCodable([1.2]))
        XCTAssertEqual(AnyCodable([true]), AnyCodable([true]))

        XCTAssertNotEqual(AnyCodable(()), AnyCodable(true))
    }

    func testVoidDescription() {
        XCTAssertEqual(String(describing: AnyCodable(Void())), "nil")
    }

    func testJSONDecoding() throws {
        let json = """
        {
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": {
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let dictionary = try decoder.decode([String: AnyCodable].self, from: json)

        XCTAssertEqual(dictionary["boolean"]?.value as! Bool, true)
        XCTAssertEqual(dictionary["integer"]?.value as! Int, 1)
        XCTAssertEqual(dictionary["double"]?.value as! Double, 3.14159265358979323846, accuracy: 0.001)
        XCTAssertEqual(dictionary["string"]?.value as! String, "string")
        XCTAssertEqual(dictionary["array"]?.value as! [Int], [1, 2, 3])
        XCTAssertEqual(dictionary["nested"]?.value as! [String: String], ["a": "alpha", "b": "bravo", "c": "charlie"])
    }

    func testJSONEncoding() throws {
        let dictionary: [String: AnyCodable] = [
            "boolean": true,
            "integer": 1,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
            ],
        ]

        let result = try testStringFromEncoding(of: dictionary)

        assertJSONEquivalent(
            result,
            """
            {
              "array" : [
                1,
                2,
                3
              ],
              "boolean" : true,
              "integer" : 1,
              "nested" : {
                "a" : "alpha",
                "b" : "bravo",
                "c" : "charlie"
              },
              "string" : "string"
            }
            """
        )
    }

    func testEncodeNSNumber() throws {
        #if os(macOS)
        let dictionary: [String: NSNumber] = [
            "boolean": true,
            "integer": 1,
        ]

        let result = try testStringFromEncoding(of: AnyCodable(dictionary))

        assertJSONEquivalent(
            result,
            """
            {
              "boolean" : true,
              "integer" : 1
            }
            """
        )
        #endif
    }

    let testEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        if #available(macOS 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }
        return encoder
    }()

    func test_encodeNil() throws {
        let data = try JSONEncoder().encode(Wrapper(value: nil as AnyCodable))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"value":null}"#)
    }

    func test_encodeBool() throws {
        let data = try JSONEncoder().encode(Wrapper(value: false as AnyCodable))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"value":false}"#)
    }

    func test_encodeInt() throws {
        let data = try JSONEncoder().encode(Wrapper(value: 2 as AnyCodable))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"value":2}"#)
    }

    func test_encodeString() throws {
        let data = try JSONEncoder().encode(Wrapper(value: "hi" as AnyCodable))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"value":"hi"}"#)
    }

    func test_encodeURL() throws {
        let data = try JSONEncoder().encode(Wrapper(value: AnyCodable(URL(string: "https://hello.com")!)))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"value":"https:\/\/hello.com"}"#)
    }

    func test_encodeEncodable() throws {
        struct TestEncodable: Codable {
            let x: String
            let y: Int
            let z: Bool?

            // NOTE: The auto-magically synthesized conformance leaves out `nil` values so we make it explicit

            enum CodingKeys: String, CodingKey {
                case x
                case y
                case z
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(x, forKey: .x)
                try container.encode(y, forKey: .y)
                if let z = self.z {
                    try container.encode(z, forKey: .z)
                } else {
                    try container.encodeNil(forKey: .z)
                }
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(AnyCodable(TestEncodable(x: "abc", y: 123, z: nil)))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"x":"abc","y":123,"z":null}"#)

        let decoder = JSONDecoder()
        _ = try decoder.decode(AnyCodable.self, from: data)
    }

    func test_encodeEncodableNested() throws {
        struct TestEncodable: Codable {
            let x: AnyCodable
            let y: AnyCodable
            let z: AnyCodable?

            // NOTE: The auto-magically synthesized conformance leaves out `nil` values so we make it explicit

            enum CodingKeys: String, CodingKey {
                case x
                case y
                case z
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(x, forKey: .x)
                try container.encode(y, forKey: .y)
                if let z = self.z {
                    try container.encode(z, forKey: .z)
                } else {
                    try container.encodeNil(forKey: .z)
                }
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(AnyCodable(TestEncodable(x: "abc", y: AnyCodable(TestEncodable(x: "", y: 0, z: true)), z: nil)))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"{"x":"abc","y":{"x":"","y":0,"z":true},"z":null}"#)

        let decoder = JSONDecoder()
        _ = try decoder.decode(AnyCodable.self, from: data)
    }

    func test_encodeEncodableArray() throws {
        struct TestEncodable: Codable {
            let x: AnyCodable
            let y: AnyCodable
            let z: AnyCodable?

            // NOTE: The auto-magically synthesized conformance leaves out `nil` values so we make it explicit

            enum CodingKeys: String, CodingKey {
                case x
                case y
                case z
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(x, forKey: .x)
                try container.encode(y, forKey: .y)
                if let z = self.z {
                    try container.encode(z, forKey: .z)
                } else {
                    try container.encodeNil(forKey: .z)
                }
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(AnyCodable([TestEncodable(x: "abc", y: 123, z: nil)]))

        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual(string, #"[{"x":"abc","y":123,"z":null}]"#)

        let decoder = JSONDecoder()
        _ = try decoder.decode(AnyCodable.self, from: data)
    }
}

fileprivate struct Wrapper: Codable {
    let value: AnyCodable
}

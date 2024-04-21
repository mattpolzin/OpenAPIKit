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

    func testEqualityFromJSON() throws {
        let json = """
        {
            "boolean": true,
                "integer": 1,
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
        let anyCodable0 = try decoder.decode(AnyCodable.self, from: json)
        let anyCodable1 = try decoder.decode(AnyCodable.self, from: json)
        XCTAssertEqual(anyCodable0, anyCodable1)
    }

    struct CustomEncodable: Encodable {
        let value1: String

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode("hi hi hi " + value1)
        }
    }

    func test_encodable() throws {
        let value = CustomEncodable(value1: "hello")
        let anyCodable = AnyCodable(value)
        let thing = try JSONEncoder().encode(anyCodable)
        XCTAssertEqual(String(data: thing, encoding: .utf8)!, "\"hi hi hi hello\"")
    }

    func testVoidDescription() {
        XCTAssertEqual(String(describing: AnyCodable(Void())), "nil")
    }

    func test_encodedDecodedURL() throws {
        let value = URL(string: "https://www.google.com")
        let anyCodable = AnyCodable(value)
        
        // URL's absoluteString compares as equal to the wrapped any codable description.
        XCTAssertEqual(value?.absoluteString, anyCodable.description)
        
        let encodedValue = try JSONEncoder().encode(value)
        let encodedAnyCodable = try JSONEncoder().encode(anyCodable)
        // the URL and the wrapped any codable encode as equals.
        XCTAssertEqual(encodedValue, encodedAnyCodable)
        
        let decodedFromValue = try JSONDecoder().decode(AnyCodable.self, from: encodedValue)
        // the URL decoded as any codable has the same description as the original any codable wrapper.
        XCTAssertEqual(anyCodable.description, decodedFromValue.description)
        
        let decodedFromAnyCodable = try JSONDecoder().decode(AnyCodable.self, from: encodedAnyCodable)
        // the decoded any codable has the same description as the original any codable wrapper.
        XCTAssertEqual(anyCodable.description, decodedFromAnyCodable.description)

        func roundTripEqual<A: Codable, B: Codable>(_ a: A, _ b: B) throws -> Bool {
            let a = try JSONDecoder().decode(AnyCodable.self, 
                                             from: JSONEncoder().encode(a))
            let b = try JSONDecoder().decode(AnyCodable.self, 
                                             from: JSONEncoder().encode(b))
            return a == b
        }
        // if you encode/decode both, the URL and its AnyCodable wrapper are equal.
        try XCTAssert(roundTripEqual(anyCodable, value))

        func encodedEqual<A: Codable, B: Codable>(_ a: A, _ b: B) throws -> Bool {
            let a = try JSONEncoder().encode(a)
            let b = try JSONEncoder().encode(b)
            return a == b
        }
        // if you just compare the encoded data, the URL and its AnyCodable wrapper are equal.
        try XCTAssert(encodedEqual(anyCodable, value))
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
}

fileprivate struct Wrapper: Codable {
    let value: AnyCodable
}

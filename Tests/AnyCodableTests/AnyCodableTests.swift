@testable import OpenAPIKitCore
import XCTest

class AnyCodableTests: XCTestCase {
    func test_equality() throws {
        XCTAssertEqual(AnyCodable.null, AnyCodable.null)
        XCTAssertEqual(AnyCodable.bool(true), AnyCodable.bool(true))
        XCTAssertEqual(AnyCodable.int(2), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable.double(2), AnyCodable.double(2))
        XCTAssertEqual(AnyCodable.string("hi"), AnyCodable.string("hi"))
        XCTAssertEqual(AnyCodable.object(["hi": .int(2)]), AnyCodable.object(["hi": .int(2)]))
        XCTAssertEqual(AnyCodable.array([.string("hi")]), AnyCodable.array([.string("hi")]))
        XCTAssertEqual(AnyCodable.array([.int(1)]), AnyCodable.array([.int(1)]))
        
        XCTAssertNotEqual(AnyCodable.null, AnyCodable.bool(true))
        XCTAssertNotEqual(AnyCodable.null, AnyCodable.int(2))
        XCTAssertNotEqual(AnyCodable.int(4), AnyCodable.string("hi"))
        XCTAssertNotEqual(AnyCodable.string("hi"), AnyCodable.array([.string("hi")]))
        XCTAssertNotEqual(AnyCodable.object(["hi": .int(2)]), AnyCodable.object(["hi": .double(3)]))
    }
    
    func test_inits() throws {
        let falseBool = false
        XCTAssertEqual(AnyCodable(()), AnyCodable.null)
        XCTAssertEqual(AnyCodable(true), AnyCodable.bool(true))
        XCTAssertEqual(AnyCodable(falseBool), AnyCodable.bool(false))
        XCTAssertEqual(AnyCodable(2), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(Int8(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(Int16(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(Int32(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(Int64(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(UInt(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(UInt8(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(UInt16(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(UInt32(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(UInt64(2)), AnyCodable.int(2))
        XCTAssertEqual(AnyCodable(Float(2)), AnyCodable.double(2))
        XCTAssertEqual(AnyCodable(Double(2)), AnyCodable.double(2))
        XCTAssertEqual(AnyCodable("hi"), AnyCodable.string("hi"))
        XCTAssertEqual(AnyCodable(["hi": 2]), AnyCodable.object(["hi": .int(2)]))
        XCTAssertEqual(AnyCodable(["hi", "there"]), AnyCodable.array([.string("hi"), .string("there")]))
        XCTAssertEqual(AnyCodable(["hi": 1]), AnyCodable.object(["hi": .int(1)]))
        XCTAssertEqual(AnyCodable([1]), AnyCodable.array([.int(1)]))
        XCTAssertEqual(AnyCodable([1.2]), AnyCodable.array([.double(1.2)]))
        XCTAssertEqual(AnyCodable([true]), AnyCodable.array([.bool(true)]))
    }
    
    func test_expressible() throws {
        XCTAssertEqual(AnyCodable.string("hi"), "hi")
        XCTAssertEqual(AnyCodable.bool(true), true)
        XCTAssertEqual(AnyCodable.null, nil)
        XCTAssertEqual(AnyCodable.int(2), 2)
        XCTAssertEqual(AnyCodable.double(3.4), 3.4)
        XCTAssertEqual(AnyCodable.object(["hi": .string("there")]), ["hi": "there"])
    }

    func test_equalityFromJSON() throws {
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

    func test_VoidDescription() {
        XCTAssertEqual(String(describing: AnyCodable(())), "nil")
    }

    func test_JSONDecodingByKeys() throws {
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

        XCTAssertEqual(dictionary["boolean"], true)
        XCTAssertEqual(dictionary["integer"], 1)
        XCTAssertEqual(dictionary["double"]!.double!, 3.14159265358979323846, accuracy: 0.001)
        XCTAssertEqual(dictionary["string"], "string")
        XCTAssertEqual(dictionary["array"], [1, 2, 3])
        XCTAssertEqual(dictionary["nested"], ["a": "alpha", "b": "bravo", "c": "charlie"])
    }

    func test_JSONDecodingFull() throws {
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
        let anyCodable = try decoder.decode(AnyCodable.self, from: json)
        
        XCTAssertEqual(
            anyCodable,
            .object(
                [
                    "boolean": .bool(true),
                    "integer": .int(1),
                    "string": .string("string"),
                    "array": .array([.int(1), .int(2), .int(3)]),
                    "nested": .object(
                        [
                            "a": .string("alpha"),
                            "b": .string("bravo"),
                            "c": .string("charlie")
                        ]
                    ),
                ]
            )
        )
    }
    
    func test_JSONEncoding() throws {
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
        let anyCodable = try AnyCodable.encoded(EncodableStruct())
        let expectedAnyCodable: AnyCodable = [
            "int": 1,
            "string": "hello",
            "bool": true,
            "array": [1, 2, 3],
            "dictionary": ["a": 1, "b": 2, "c": 3],
            "data": "aGVsbG8=",
            "decimal": 10.0,
            "url": "https://google.com"
        ]
        XCTAssertEqual(anyCodable, expectedAnyCodable)

        let data = try JSONEncoder().encode(anyCodable)
        let decodedValue = try JSONDecoder().decode(EncodableStruct.self, from: data)
        XCTAssertEqual(decodedValue, EncodableStruct())
    }
    
    func test_dateEncodableInit() throws {
        let anyCodable = try AnyCodable.encoded(
            EncodableStruct(),
            keyEncodingStrategy: .default
        )
        let expectedAnyCodable: AnyCodable = [
            "int": 1,
            "string": "hello",
            "bool": true,
            "array": [1, 2, 3],
            "dictionary": ["a": 1, "b": 2, "c": 3],
            "data": "aGVsbG8=",
            "decimal": 10.0,
            "url": "https://google.com"
        ]
        XCTAssertEqual(anyCodable, expectedAnyCodable)
        
        let data = try JSONEncoder().encode(anyCodable)
        let decodedValue = try JSONDecoder().decode(EncodableStruct.self, from: data)
        XCTAssertEqual(decodedValue, EncodableStruct())
    }

    func test_keyEncodingStrategy() throws {
        let camelCaseString = "thisIsCamelCase"
        XCTAssertEqual(KeyEncodingStrategy.convertToSnakeCase.encode(camelCaseString), "this_is_camel_case")

        let anyCodable = try AnyCodable.encoded(StructWithLargeNameProperty(), keyEncodingStrategy: .convertToSnakeCase)
        let expectedAnyCodable: AnyCodable = [
            "this_is_a_very_long_property_name_that_will_be_encoded": "hello",
        ]
        XCTAssertEqual(anyCodable, expectedAnyCodable)
    }

    func test_dateEncodingStrategies() throws {
        let date = Date(timeIntervalSince1970: 0)
        let anyCodable = try AnyCodable.encoded(date, valueEncodingStrategies: [.Date.timestamp])
        let expectedAnyCodable: AnyCodable = 0.0
        XCTAssertEqual(anyCodable, expectedAnyCodable)

        let data = try JSONEncoder().encode([anyCodable]) // Use array for swift 5.1 support
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "[0]")

        let anyCodable3 = try AnyCodable.encoded(date, valueEncodingStrategies: [.Date.dateTime])
        let expectedAnyCodable3: AnyCodable = "1970-01-01T00:00:00.000Z"
        XCTAssertEqual(anyCodable3, expectedAnyCodable3)

        let data3 = try JSONEncoder().encode([anyCodable3]) // Use array for swift 5.1 support
        let string3 = String(data: data3, encoding: .utf8)
        XCTAssertEqual(string3, #"["1970-01-01T00:00:00.000Z"]"#)

        let anyCodable4 = try AnyCodable.encoded(date, valueEncodingStrategies: [.Date.date])
        let expectedAnyCodable4: AnyCodable = "1970-01-01"
        XCTAssertEqual(anyCodable4, expectedAnyCodable4)

        let data4 = try JSONEncoder().encode([anyCodable4]) // Use array for swift 5.1 support
        let string4 = String(data: data4, encoding: .utf8)
        XCTAssertEqual(string4, #"["1970-01-01"]"#)
    }
    
    func test_dataEncodingStrategies() throws {
        let data = Data([0x01, 0x02, 0x03])
        let anyCodable1 = try AnyCodable.encoded(data, valueEncodingStrategies: [.Data.base64])
        let expectedAnyCodable1: AnyCodable = "AQID"
        XCTAssertEqual(anyCodable1, expectedAnyCodable1)
        
        let data1 = try JSONEncoder().encode([anyCodable1]) // Use array for swift 5.1 support
        let string1 = String(data: data1, encoding: .utf8)
        XCTAssertEqual(string1, #"["AQID"]"#)
        
        let anyCodable2 = try AnyCodable.encoded(data, valueEncodingStrategies: [.Data.base64(options: .endLineWithCarriageReturn)])
        let expectedAnyCodable2: AnyCodable = "AQID"
        XCTAssertEqual(anyCodable2, expectedAnyCodable2)
        
        let data2 = try JSONEncoder().encode([anyCodable2]) // Use array for swift 5.1 support
        let string2 = String(data: data2, encoding: .utf8)
        XCTAssertEqual(string2, #"["AQID"]"#)
    }
    
    func test_urlEncodingStrategies() throws {
        let url = URL(string: "https://google.com")!
        let anyCodable = try AnyCodable.encoded(url, valueEncodingStrategies: [.URL.uri])
        let expectedAnyCodable: AnyCodable = "https://google.com"
        XCTAssertEqual(anyCodable, expectedAnyCodable)
        
        let data = try JSONEncoder().encode([anyCodable]) // Use array for swift 5.1 support
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, #"["https:\/\/google.com"]"#)
    }
    
    func test_decimalEncodingStrategies() throws {
        let decimal = Decimal(10)
        
        let anyCodable1 = try AnyCodable.encoded(decimal, valueEncodingStrategies: [.Decimal.number])
        let expectedAnyCodable1: AnyCodable = 10.0
        XCTAssertEqual(anyCodable1, expectedAnyCodable1)
        
        let data1 = try JSONEncoder().encode([anyCodable1]) // Use array for swift 5.1 support
        let string1 = String(data: data1, encoding: .utf8)
        XCTAssertEqual(string1, "[10]")
        
        let anyCodable2 = try AnyCodable.encoded(decimal, valueEncodingStrategies: [.Decimal.string])
        let expectedAnyCodable2: AnyCodable = "10"
        XCTAssertEqual(anyCodable2, expectedAnyCodable2)
        
        let data2 = try JSONEncoder().encode([anyCodable2]) // Use array for swift 5.1 support
        let string2 = String(data: data2, encoding: .utf8)
        XCTAssertEqual(string2, #"["10"]"#)
    }
    
    func test_RefInit() {
        var value = 0
        let ref = Ref(get: {
            value
        }, set: {
            value = $0
        })
        XCTAssertEqual(ref.wrappedValue, 0)
        ref.wrappedValue = 1
        XCTAssertEqual(ref.wrappedValue, 1)
    }
    
    func test_RefConstant() {
        let ref = Ref.constant(1)
        XCTAssertEqual(ref.wrappedValue, 1)
        ref.wrappedValue = 2
        XCTAssertEqual(ref.wrappedValue, 1)
    }
    
    func test_RefByKeyPath() {
        let ref = Ref(DateFormatter(), \.dateFormat)
        ref.wrappedValue = "yyyy-MM-dd"
        XCTAssertEqual(ref.wrappedValue, "yyyy-MM-dd")
        ref.wrappedValue = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        XCTAssertEqual(ref.wrappedValue, "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
    
    func test_description() {
        XCTAssertEqual(AnyCodable(0).description, "0")
        XCTAssertEqual(AnyCodable(0.0).description, "0.0")
        XCTAssertEqual(AnyCodable(()).description, "nil")
        XCTAssertEqual(AnyCodable("hello").description, "\"hello\"")
        XCTAssertEqual(AnyCodable(true).description, "true")
        XCTAssertEqual(AnyCodable(false).description, "false")
        XCTAssertEqual(AnyCodable([1, 2, 3]).description, "[1, 2, 3]")
        XCTAssertEqual(AnyCodable(["a": 1, "b": 2]).description, "[\"a\": 1, \"b\": 2]")
    }
    
    func test_debugDescription() {
        XCTAssertEqual(AnyCodable(0).debugDescription, "AnyCodable(0)")
        XCTAssertEqual(AnyCodable(0.0).debugDescription, "AnyCodable(0.0)")
        XCTAssertEqual(AnyCodable(()).debugDescription, "AnyCodable(nil)")
        XCTAssertEqual(AnyCodable("hello").debugDescription, "AnyCodable(\"hello\")")
        XCTAssertEqual(AnyCodable(true).debugDescription, "AnyCodable(true)")
        XCTAssertEqual(AnyCodable(false).debugDescription, "AnyCodable(false)")
        XCTAssertEqual(AnyCodable([1, 2, 3]).debugDescription, "AnyCodable([1, 2, 3])")
        XCTAssertEqual(AnyCodable(["a": 1, "b": 2]).debugDescription, "AnyCodable([\"a\": 1, \"b\": 2])")
    }
}

private struct Wrapper: Codable {
    let value: AnyCodable
}

private struct EncodableStruct: Codable, Equatable {
    var int = 1
    var string = "hello"
    var bool = true
    var array = [1, 2, 3]
    var dictionary = ["a": 1, "b": 2, "c": 3]
    var data = "hello".data(using: .utf8)
    var decimal = Decimal(10)
    var url = URL(string: "https://google.com")!
}

private struct StructWithLargeNameProperty: Codable {
    var thisIsAVeryLongPropertyNameThatWillBeEncoded: String = "hello"
}

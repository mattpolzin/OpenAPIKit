//
//  OrderedDictionaryTests.swift
//  OpenAPIKit - OrderedDictionaryTests
//
//  Created by Mathew Polzin on 1/17/20.
//

import OpenAPIKit
import XCTest
import Yams
import FineJSON

final class OrderedDictionaryTests: XCTestCase {
    func test_initGrouping() {
        let numbers = ["10", "10.0", "11"]

        let dict = OrderedDictionary(
            grouping: numbers,
            by: { Double($0) }
        )

        XCTAssertEqual(
            dict,
            [
                10: ["10", "10.0"],
                11: ["11"]
            ]
        )
    }

    func test_initKeysAndValues() {
         let keysAndValues = [
            (10, "10.0"),
            (11, "11"),
            (10, "10")
        ]

        let dict = OrderedDictionary(
            keysAndValues,
            uniquingKeysWith: { $1 }
        )

        XCTAssertEqual(
            dict,
            [
                10: "10",
                11: "11"
            ]
        )
    }

    func test_keySubscriptGet() {
        let dict: OrderedDictionary = [
            "hello": "world",
            "hi": "there",
            "a": "test",
            "the": "best"
        ]

        XCTAssertEqual(dict["hello"], "world")
        XCTAssertEqual(dict["hi"], "there")
        XCTAssertEqual(dict["a"], "test")
        XCTAssertEqual(dict["the"], "best")
    }

    func test_keySubscriptSet() {
        var dict = OrderedDictionary<String, String>()

        dict = [
            "hello": "world",
            "hi": "there",
            "a": "test"
        ]

        dict["hello"] = "there"
        dict["hi"] = "mom"
        dict["a"] = "program"
        dict["the"] = "best"

        XCTAssertEqual(dict["hello"], "there")
        XCTAssertEqual(dict["hi"], "mom")
        XCTAssertEqual(dict["a"], "program")
        XCTAssertEqual(dict["the"], "best")

        XCTAssertEqual(dict.values, ["there", "mom", "program", "best"])

        dict["hi"] = nil

        XCTAssertEqual(dict.count, 3)
        XCTAssertNil(dict["hi"])
        XCTAssertEqual(dict.values, ["there", "program", "best"])
    }

    func test_indexSubscriptGet() {
        let dict: OrderedDictionary = [
            "hello": "world",
            "hi": "there",
            "a": "test",
            "the": "best"
        ]

        XCTAssert(dict[0] == ("hello", "world"))
        XCTAssert(dict[1] == ("hi", "there"))
        XCTAssert(dict[2] == ("a", "test"))
        XCTAssert(dict[3] == ("the", "best"))
    }

    func test_defaultingSubscriptGet() {
        let dict: OrderedDictionary = ["hello": "world"]

        let hello = dict["hello", default: "there"]
        let hi = dict["hi", default: "there"]

        XCTAssertEqual(hello, "world")
        XCTAssertEqual(hi, "there")
    }

    func test_defaultingSubscriptModify() {
        var dict: OrderedDictionary = ["hello": "world"]

        dict["hello", default: "there"] += " user."
        dict["hi", default: "there"] += " user."

        XCTAssertEqual(
            dict,
            [
                "hello": "world user.",
                "hi": "there user."
            ]
        )
    }

    func test_mapValues() {
        let dict: OrderedDictionary = [
            "hello": "1",
            "hi": "2",
            "a": "3",
            "the": "4"
        ]

        let dict2 = dict.mapValues { Int($0)! }

        XCTAssertEqual(dict2.values, [1, 2, 3, 4])
    }

    func test_compactMapValues() {
        let dict: OrderedDictionary = [
            "hello": "1",
            "hi": "2",
            "a": "hi",
            "the": "4"
        ]

        let dict2 = dict.compactMapValues { Int($0) }

        XCTAssertEqual(dict2.count, 3)
        XCTAssertEqual(dict2.values, [1, 2, 4])
        XCTAssertEqual(dict2.keys, ["hello", "hi", "the"])
    }

    func test_containsWhereKey() {
        let dict: OrderedDictionary = [
            "hello": "1",
            "hi": "2",
            "a": "hi",
            "the": "4"
        ]

        XCTAssertTrue(dict.contains { $0 == "hello" })
        XCTAssertFalse(dict.contains { $0 == "there" })
    }

    func test_containsKey() {
        let dict: OrderedDictionary = [
            "hello": "1",
            "hi": "2",
            "a": "hi",
            "the": "4"
        ]

        XCTAssertTrue(dict.contains(key: "hello"))
        XCTAssertFalse(dict.contains(key: "there"))
    }
}

// MARK: - Codable
extension OrderedDictionaryTests {
    // Sadly JSONEncoder does not retain order for Linux Foundation
    func test_stringKeyEncode() throws {
        let dict: OrderedDictionary = [
            "hello": "world",
            "a": "thing"
        ]

        let encodedDict = String(
            data: try FineJSONEncoder().encode(dict),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict,
"""
{
  "hello": "world",
  "a": "thing"
}
"""
        )

        let dict2: OrderedDictionary = [
            "a": "world",
            "hello": "thing"
        ]

        let encodedDict2 = String(
            data: try FineJSONEncoder().encode(dict2),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict2,
"""
{
  "a": "world",
  "hello": "thing"
}
"""
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSON, not JSONDecoder
    func test_stringKeyDecode() throws {
        let dictString =
"""
hello: world
a: thing
"""

        let dict = try YAMLDecoder().decode(OrderedDictionary<String, String>.self, from: dictString)

        XCTAssertEqual(
            dict,
            ["hello": "world", "a": "thing"]
        )

        let dictString2 =
"""
a: world
hello: thing
"""

        let dict2 = try YAMLDecoder().decode(OrderedDictionary<String, String>.self, from: dictString2)

        XCTAssertEqual(
            dict2,
            ["a": "world", "hello": "thing"]
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_stringKeyDecode2() throws {
        let dictData =
"""
{"hello": "world",
"a": "thing"}
""".data(using: .utf8)!

        let dict = try FineJSONDecoder().decode(OrderedDictionary<String, String>.self, from: dictData)

        XCTAssertEqual(
            dict,
            ["hello": "world", "a": "thing"]
        )

        let dictData2 =
"""
{"a": "world",
"hello": "thing"}
""".data(using: .utf8)!

        let dict2 = try FineJSONDecoder().decode(OrderedDictionary<String, String>.self, from: dictData2)

        XCTAssertEqual(
            dict2,
            ["a": "world", "hello": "thing"]
        )
    }

    // Sadly JSONEncoder does not retain order for Linux Foundation
    func test_doubleKeyEncode() throws {
        //        // should use lossless
        //        let dict: OrderedDictionary = [
        //            10.0: "world",
        //            7.5: "thing"
        //        ]
        //
        //        print(dict.map { $0 })
        //
        //        let encodedDict = String(
        //            data: try JSONEncoder().encode(dict),
        //            encoding: .utf8
        //        )!
        //
        //        print(encodedDict)
        //
        //        XCTAssertEqual(
        //            encodedDict,
        //"""
        //{"10.0":"world","7.5":"thing"}
        //"""
        //        )

        // should use lossless
        let dict2: OrderedDictionary = [
            1.0: "world",
            7.0: "thing"
        ]

        let encodedDict2 = String(
            data: try FineJSONEncoder().encode(dict2),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict2,
"""
{
  "1.0": "world",
  "7.0": "thing"
}
"""
        )

        // should use lossless
        let dict3: OrderedDictionary = [
            100.5: "world",
            8.5: "thing"
        ]

        let encodedDict3 = String(
            data: try FineJSONEncoder().encode(dict3),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict3,
"""
{
  "100.5": "world",
  "8.5": "thing"
}
"""
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_doubleKeyDecode() throws {
        let dictString =
"""
1.0: world
7.0: thing
"""

        let dict = try YAMLDecoder().decode(OrderedDictionary<Double, String>.self, from: dictString)

        XCTAssertEqual(
            dict,
            [1.0: "world", 7.0: "thing"]
        )

        let dictString2 =
"""
100.5: world
8.5: thing
"""

        let dict2 = try YAMLDecoder().decode(OrderedDictionary<Double, String>.self, from: dictString2)

        XCTAssertEqual(
            dict2,
            [100.5: "world", 8.5: "thing"]
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_doubleKeyDecode2() throws {
        let dictData =
"""
{"1.0": "world",
"7.0": "thing"}
""".data(using: .utf8)!

        let dict = try FineJSONDecoder().decode(OrderedDictionary<Double, String>.self, from: dictData)

        XCTAssertEqual(
            dict,
            [1.0: "world", 7.0: "thing"]
        )

        let dictData2 =
"""
{"100.5": "world",
"8.5": "thing"}
""".data(using: .utf8)!

        let dict2 = try FineJSONDecoder().decode(OrderedDictionary<Double, String>.self, from: dictData2)

        XCTAssertEqual(
            dict2,
            [100.5: "world", 8.5: "thing"]
        )
    }

    // Sadly JSONEncoder does not retain order for Linux Foundation
    func test_intKeyEncode() throws {
        // should use lossless
        let dict: OrderedDictionary = [
            3: "world",
            2: "thing"
        ]

        let encodedDict = String(
            data: try FineJSONEncoder().encode(dict),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict,
"""
{
  "3": "world",
  "2": "thing"
}
"""
        )

        let dict2: OrderedDictionary = [
            2: "world",
            3: "thing"
        ]

        let encodedDict2 = String(
            data: try FineJSONEncoder().encode(dict2),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict2,
"""
{
  "2": "world",
  "3": "thing"
}
"""
        )

        let dict3: OrderedDictionary = [
            20: "world",
            3: "thing"
        ]

        let encodedDict3 = String(
            data: try FineJSONEncoder().encode(dict3),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict3,
"""
{
  "20": "world",
  "3": "thing"
}
"""
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_intKeyDecode() throws {
        let dictString =
"""
1: world
7: thing
"""

        let dict = try YAMLDecoder().decode(OrderedDictionary<Int, String>.self, from: dictString)

        XCTAssertEqual(
            dict,
            [1: "world", 7: "thing"]
        )

        let dictString2 =
"""
100: world
8: thing
"""

        let dict2 = try YAMLDecoder().decode(OrderedDictionary<Int, String>.self, from: dictString2)

        XCTAssertEqual(
            dict2,
            [100: "world", 8: "thing"]
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_intKeyDecode2() throws {
        let dictData =
"""
{"1": "world",
"7": "thing"}
""".data(using: .utf8)!

        let dict = try FineJSONDecoder().decode(OrderedDictionary<Int, String>.self, from: dictData)

        XCTAssertEqual(
            dict,
            [1: "world", 7: "thing"]
        )

        let dictData2 =
"""
{"100": "world",
"8": "thing"}
""".data(using: .utf8)!

        let dict2 = try FineJSONDecoder().decode(OrderedDictionary<Int, String>.self, from: dictData2)

        XCTAssertEqual(
            dict2,
            [100: "world", 8: "thing"]
        )
    }

    // Sadly JSONEncoder does not retain order for Linux Foundation
    func test_stringEnumKeyEncode() throws {
        let dict: OrderedDictionary = [
            TestKey.hello: "here",
            TestKey.world: "there"
        ]

        let encodedDict = String(
            data: try FineJSONEncoder().encode(dict),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict,
"""
{
  "hello": "here",
  "world": "there"
}
"""
        )

        let dict2: OrderedDictionary = [
            TestKey.world: "here",
            TestKey.hello: "there"
        ]

        let encodedDict2 = String(
            data: try FineJSONEncoder().encode(dict2),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict2,
"""
{
  "world": "here",
  "hello": "there"
}
"""
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_stringEnumKeyDecode() throws {
        let dictString =
"""
hello: world
world: thing
"""

        let dict = try YAMLDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictString)

        XCTAssertEqual(
            dict,
            [.hello: "world", .world: "thing"]
        )

        let dictString2 =
"""
world: world
hello: thing
"""

        let dict2 = try YAMLDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictString2)

        XCTAssertEqual(
            dict2,
            [.world: "world", .hello: "thing"]
        )
    }

    // sadly, ordering works for YAMLDecoder and FineJSONDecoder, not JSONDecoder
    func test_stringEnumKeyDecode2() throws {
        let dictData =
"""
{"hello": "world",
"world": "thing"}
""".data(using: .utf8)!

        let dict = try FineJSONDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictData)

        XCTAssertEqual(
            dict,
            [.hello: "world", .world: "thing"]
        )

        let dictData2 =
"""
{"world": "world",
"hello": "thing"}
""".data(using: .utf8)!

        let dict2 = try FineJSONDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictData2)

        XCTAssertEqual(
            dict2,
            [.world: "world", .hello: "thing"]
        )
    }

    func test_otherKeyEncode() throws {
        let dict: OrderedDictionary = [
            TestKey2("x"): "hello",
            TestKey2("y"): "there"
        ]

        let encodedDict = String(
            data: try JSONEncoder().encode(dict),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedDict,
"""
[{"x":"x"},"hello",{"x":"y"},"there"]
"""
        )
    }

    func test_otherKeyDecodeYAML() throws {
        let dictString =
"""
[
x: x,
hello,
x: y,
there
]
"""

        let dict = try YAMLDecoder().decode(OrderedDictionary<TestKey2, String>.self, from: dictString)

        XCTAssertEqual(
            dict,
            [TestKey2("x"): "hello", TestKey2("y"): "there"]
        )

        let dictString2 =
"""
[
x: y,
there,
x: x,
hello
]
"""

        let dict2 = try YAMLDecoder().decode(OrderedDictionary<TestKey2, String>.self, from: dictString2)

        XCTAssertEqual(
            dict2,
            [TestKey2("y"): "there", TestKey2("x"): "hello"]
        )
    }

    func test_otherKeyDecodeJSON() throws {
        let dictData =
"""
[
{"x": "x"},
"hello",
{"x": "y"},
"there"
]
""".data(using: .utf8)!

        let dict = try JSONDecoder().decode(OrderedDictionary<TestKey2, String>.self, from: dictData)

        XCTAssertEqual(
            dict,
            [TestKey2("x"): "hello", TestKey2("y"): "there"]
        )

        let dictData2 =
"""
[
{"x": "y"},
"there",
{"x": "x"},
"hello"
]
""".data(using: .utf8)!

        let dict2 = try JSONDecoder().decode(OrderedDictionary<TestKey2, String>.self, from: dictData2)

        XCTAssertEqual(
            dict2,
            [TestKey2("y"): "there", TestKey2("x"): "hello"]
        )
    }

    func test_otherKeyDecodeFineJSON() throws {
        let dictData =
"""
[
{"x": "x"},
"hello",
{"x": "y"},
"there"
]
""".data(using: .utf8)!

        let dict = try FineJSONDecoder().decode(OrderedDictionary<TestKey2, String>.self, from: dictData)

        XCTAssertEqual(
            dict,
            [TestKey2("x"): "hello", TestKey2("y"): "there"]
        )

        let dictData2 =
"""
[
{"x": "y"},
"there",
{"x": "x"},
"hello"
]
""".data(using: .utf8)!

        let dict2 = try FineJSONDecoder().decode(OrderedDictionary<TestKey2, String>.self, from: dictData2)

        XCTAssertEqual(
            dict2,
            [TestKey2("y"): "there", TestKey2("x"): "hello"]
        )
    }

    func test_failedKeyDecodeYAML() {
        let dictString =
"""
[
x: x
]
"""

        XCTAssertThrowsError(try YAMLDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictString))
    }

    func test_failedKeyDecodeJSON() {
        let dictData =
"""
[
{"x": "x"}
]
""".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictData))
    }

    func test_failedKeyDecodeFineJSON() {
        let dictData =
"""
[
{"x": "x"},
"hello",
{"x": "y"},
"there"
]
""".data(using: .utf8)!

        XCTAssertThrowsError(try FineJSONDecoder().decode(OrderedDictionary<TestKey, String>.self, from: dictData))
    }
}

fileprivate enum TestKey: String, RawRepresentable, Codable {
    case hello
    case world
}

fileprivate struct TestKey2: Hashable, Codable {
    let x: String

    init(_ x: String) { self.x = x }
}

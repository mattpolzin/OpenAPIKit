//
//  EitherTests.swift
//  OpenAPIKit - EitherTests
//
//  Created by Mathew Polzin on 11/23/18.
//

import XCTest
import Foundation
@testable import OpenAPIKit

// MARK: - init
class EitherTests: XCTestCase {

	func test_init_Either() {
		let entity = MatchingType(zzzzz: "hello world")
		let either = Either<MatchingType, TestType1>(entity)
		XCTAssertEqual(either.a, entity)
		XCTAssertNil(either.b)

		let either2 = Either<TestType1, MatchingType>(entity)
		XCTAssertEqual(either2.b, entity)
		XCTAssertNil(either2.a)
	}
}

// MARK: - mapping with protocol
extension EitherTests {
	func test_mapWithProtocol() {
		let testThings: [Either<TestType1, TestType2>] = [
			.init(TestType1(a: 1)),
			.init(TestType2(b: 2))
		]

		let testString = testThings.map { $0.test }.joined(separator: " ")

		XCTAssertEqual(testString, "Hello There")
	}
}

// MARK: - failures
extension EitherTests {
	func test_Either_decode_throws_typeNotFound() {
		XCTAssertThrowsError(try JSONDecoder().decode(Either<TestType1, TestType2>.self, from: either_entity3))
	}
}

// MARK: - decoding ambiguity

extension EitherTests {
    func test_DoubleThenInt() {
        // Either<Double, Int> is ambiguous when decoding a number that could be either
        // a Double or an Int. Either will pick the first possible match.

        struct Test: Decodable, Equatable {
            let x: Either<Double, Int>
        }

        let data = #"{ "x": 2 }"#.data(using: .utf8)!

        XCTAssertEqual(try? JSONDecoder().decode(Test.self, from: data), Test(x: .a(2)))
    }

    func test_IntThenDouble() {
        // Either<Int, Double> avoids some ambiguity since a number that could be an Int can also
        // be a Double but not the other way around. If you expect a particular number that is
        // possible to represent as an Int to become a Double, you are still not able to use this
        // type.

        struct Test: Decodable, Equatable {
            let x: Either<Int, Double>
        }

        let data = #"{ "x": 2 }"#.data(using: .utf8)!

        XCTAssertEqual(try? JSONDecoder().decode(Test.self, from: data), Test(x: .a(2)))

        let data2 = #"{ "x": 2.1 }"#.data(using: .utf8)!

        XCTAssertEqual(try? JSONDecoder().decode(Test.self, from: data2), Test(x: .b(2.1)))
    }
}

// MARK: - debug output
extension EitherTests {
    func test_EitherTypeNotFoundOutput() {
        do {
            let _ = try JSONDecoder().decode(Either<TestType1, TestType2>.self, from: either_entity3)
        } catch {
            XCTAssertNotNil((error as? EitherDecodeNoTypesMatchedError).debugDescription)
//            print(error)
        }
    }
}

// MARK: - Test types
extension EitherTests {
    struct MatchingType: Codable, Equatable {
        let zzzzz: String
    }

	struct TestType1: Codable, Equatable {
		let a: Int
	}

	struct TestType2: Codable, Equatable {
		let b: Int
	}

	struct TestType3: Codable, Equatable {
		let c: Int
	}
}

protocol TestProtocol {
	var test: String { get }
}

extension EitherTests.TestType1: TestProtocol {
	var test: String { return "Hello" }
}

extension EitherTests.TestType2: TestProtocol {
	var test: String { return "There" }
}

extension Either: TestProtocol where A == EitherTests.TestType1, B == EitherTests.TestType2 {
	var test: String {
		switch self {
		case .a(let x as TestProtocol),
			 .b(let x as TestProtocol):
			return x.test
		}
	}
}

let matching_entity = """
{
    "zzzzz": "hello world"
}
""".data(using: .utf8)!

let either_entity1 = """
{
	"a": 1
}
""".data(using: .utf8)!

let either_entity2 = """
{
	"b": 1
}
""".data(using: .utf8)!

let either_entity3 = """
{
	"c": 1
}
""".data(using: .utf8)!


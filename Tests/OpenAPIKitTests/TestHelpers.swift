//
//  TestHelpers.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import Foundation
@preconcurrency import Yams
import XCTest

fileprivate func foundationTestEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(macOS 10.13, *) {
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    #if os(Linux)
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    #endif
    return encoder
}

func orderUnstableEncode<T: Encodable>(_ value: T) throws -> Data {
    return try foundationTestEncoder().encode(value)
}

func orderUnstableTestStringFromEncoding<T: Encodable>(of entity: T) throws -> String? {
    return String(data: try orderUnstableEncode(entity), encoding: .utf8)
}

fileprivate func yamsTestEncoder() -> YAMLEncoder {
    return YAMLEncoder()
}

func orderStableYAMLEncode<T: Encodable>(_ value: T) throws -> String {
    return try yamsTestEncoder().encode(value)
}

fileprivate func buildFoundationTestDecoder(_ userInfo: [CodingUserInfoKey: any Sendable] = [:]) -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.userInfo = userInfo
    if #available(macOS 10.12, *) {
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
    }
    #if os(Linux)
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .useDefaultKeys
    #endif
    return decoder
}

fileprivate func foundationTestDecoder() -> JSONDecoder { buildFoundationTestDecoder() }

func orderUnstableDecode<T: Decodable>(_ type: T.Type, from data: Data, userInfo : [CodingUserInfoKey: any Sendable] = [:]) throws -> T {
    return try buildFoundationTestDecoder(userInfo).decode(T.self, from: data)
}

fileprivate func yamsTestDecoder() -> YAMLDecoder {
    return YAMLDecoder()
}

func orderStableDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    return try yamsTestDecoder().decode(T.self, from: data)
}

func assertJSONEquivalent(_ str1: String?, _ str2: String?, file: StaticString = #file, line: UInt = #line) {

    // when testing on Linux, pretty printing has slightly different
    // meaning so the tests pass on OS X as written but need whitespace
    // stripped to pass on Linux
    #if os(Linux)
    var str1 = str1
    var str2 = str2

    str1?.removeAll { $0.isWhitespace }
    str2?.removeAll { $0.isWhitespace }
    #endif

    XCTAssertEqual(
        str1,
        str2,
        file: (file),
        line: line
    )
}

let emptyStringDict = [String: String]()

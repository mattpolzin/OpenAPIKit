//
//  TestHelpers.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import Foundation
import FineJSON
import PureSwiftJSON
import XCTest

// MARK: - Order-instable Encoder
fileprivate let foundationTestEncoder = { () -> JSONEncoder in
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
}()

fileprivate let pureSwiftTestEncoder = { () -> PSJSONEncoder in
    return PSJSONEncoder()
}()

func orderUnstableEncode<T: Encodable>(_ value: T) throws -> Data {
//    return try foundationTestEncoder.encode(value)
    return try Data(pureSwiftTestEncoder.encode(value))
}

func orderUnstableTestStringFromEncoding<T: Encodable>(of entity: T) throws -> String? {
    return String(data: try orderUnstableEncode(entity), encoding: .utf8)
}

// MARK: - Order-stable Encoder
fileprivate let fineJSONTestEncoder = { () -> FineJSONEncoder in
    return FineJSONEncoder()
}()

func orderStableEncode<T: Encodable>(_ value: T) throws -> Data {
    return try fineJSONTestEncoder.encode(value)
}

// MARK: - Order-unstable Decoder
fileprivate let foundationTestDecoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    if #available(macOS 10.12, *) {
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
    }
    #if os(Linux)
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .useDefaultKeys
    #endif
    return decoder
}()

fileprivate let pureSwiftTestDecoder = { () -> PSJSONDecoder in
    return PSJSONDecoder()
}()

func orderUnstableDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
//    return try foundationTestDecoder.decode(T.self, from: data)
    return try pureSwiftTestDecoder.decode(T.self, from: data)
}

// MARK: - Order-stable Decoder
fileprivate let fineJSONTestDecoder = { () -> FineJSONDecoder in
    return FineJSONDecoder()
}()

func orderStableDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    return try fineJSONTestDecoder.decode(T.self, from: data)
}

// MARK: - JSON equivalency
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
        file: file,
        line: line
    )
}

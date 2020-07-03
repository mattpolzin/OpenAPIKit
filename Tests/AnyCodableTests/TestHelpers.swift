//
//  TestHelpers.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import XCTest

let testEncoder = { () -> JSONEncoder in
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

func testStringFromEncoding<T: Encodable>(of entity: T) throws -> String? {
    return String(data: try testEncoder.encode(entity), encoding: .utf8)
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
        file: file,
        line: line
    )
}

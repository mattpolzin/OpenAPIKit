//
//  TestHelpers.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import Foundation

@available(OSX 10.13, *)
let testEncoder = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
}()

@available(OSX 10.13, *)
func testStringFromEncoding<T: Encodable>(of entity: T) throws -> String? {
    return String(data: try testEncoder.encode(entity), encoding: .utf8)
}

@available(OSX 10.12, *)
let testDecoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .useDefaultKeys
    return decoder
}()

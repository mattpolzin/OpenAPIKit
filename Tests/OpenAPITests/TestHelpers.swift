//
//  TestHelpers.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import Foundation

let testEncoder = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
}()

func testStringFromEncoding<T: Encodable>(of entity: T) throws -> String? {
    return String(data: try testEncoder.encode(entity), encoding: .utf8)
}

let testDecoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

//
//  Container+DecodeURLAsString.swift
//  
//
//  Created by Mathew Polzin on 7/5/20.
//

import Foundation

extension KeyedDecodingContainerProtocol {
    internal func decodeURLAsString(forKey key: Self.Key) throws -> URL {
        let string = try decode(String.self, forKey: key)
        let url: URL?
        #if canImport(FoundationEssentials)
        url = URL(string: string, encodingInvalidCharacters: false)
        #elseif os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            url = URL(string: string, encodingInvalidCharacters: false)
        } else {
            url = URL(string: string)
        }
        #else
        url = URL(string: string)
        #endif
        guard let url else {
            throw GenericError(
                subjectName: key.stringValue,
                details: "If specified, must be a valid URL",
                codingPath: codingPath
            )
        }
        return url
    }

    internal func decodeURLAsStringIfPresent(forKey key: Self.Key) throws -> URL? {
        guard let string = try decodeIfPresent(String.self, forKey: key) else  {
            return nil
        }

        let url: URL?
        #if canImport(FoundationEssentials)
        url = URL(string: string, encodingInvalidCharacters: false)
        #elseif os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            url = URL(string: string, encodingInvalidCharacters: false)
        } else {
            url = URL(string: string)
        }
        #else
        url = URL(string: string)
        #endif
        guard let url else {
            throw GenericError(
                subjectName: key.stringValue,
                details: "If specified, must be a valid URL",
                codingPath: codingPath
            )
        }
        return url
    }
}

//
//  Container+DecodeURLAsString.swift
//  
//
//  Created by Mathew Polzin on 7/5/20.
//

import OpenAPIKitCore
import Foundation

extension KeyedDecodingContainerProtocol {
    internal func decodeURLAsString(forKey key: Self.Key) throws -> URL {
        let string = try decode(String.self, forKey: key)
        let urlCandidate: URL?
#if canImport(FoundationEssentials)
        urlCandidate = URL(string: string, encodingInvalidCharacters: false)
#elseif os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            urlCandidate = URL(string: string, encodingInvalidCharacters: false)
        } else {
            urlCandidate = URL(string: string)
        }
#else
        urlCandidate = URL(string: string)
#endif
        guard let url = urlCandidate else {
            throw InconsistencyError(
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

        let urlCandidate: URL?
#if canImport(FoundationEssentials)
        urlCandidate = URL(string: string, encodingInvalidCharacters: false)
#elseif os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            urlCandidate = URL(string: string, encodingInvalidCharacters: false)
        } else {
            urlCandidate = URL(string: string)
        }
#else
        urlCandidate = URL(string: string)
#endif
        guard let url = urlCandidate else {
            throw InconsistencyError(
                subjectName: key.stringValue,
                details: "If specified, must be a valid URL",
                codingPath: codingPath
            )
        }
        return url
    }
}

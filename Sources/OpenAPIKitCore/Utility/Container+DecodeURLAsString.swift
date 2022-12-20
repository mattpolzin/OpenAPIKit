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
        guard let url = URL(string: string) else {
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

        guard let url = URL(string: string) else {
            throw InconsistencyError(
                subjectName: key.stringValue,
                details: "If specified, must be a valid URL",
                codingPath: codingPath
            )
        }
        return url
    }
}

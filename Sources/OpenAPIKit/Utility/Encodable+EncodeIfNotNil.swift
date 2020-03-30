//
//  Encodable+EncodeIfNotNil.swift
//  
//
//  Created by Mathew Polzin on 11/3/19.
//

extension Optional where Wrapped: Encodable {
    /// Encode self if not `nil`, otherwise omit.
    internal func encodeIfNotNil<T: KeyedEncodingContainerProtocol>(to container: inout T, forKey key: T.Key) throws {
        if self != nil {
            try container.encode(self, forKey: key)
        }
    }
}

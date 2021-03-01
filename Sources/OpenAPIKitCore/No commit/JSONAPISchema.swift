//
//  File.swift
//  
//
//  Created by Mathew Polzin on 6/26/19.
//

//import Foundation
//import AnyCodable
//
//public enum JSONAPI {
//    public static func resourceObject(
//        jsonType: String,
//        attributes: [String: JSONSchema],
//        relationships: [String: JSONReference<JSONSchema>]
//    ) -> JSONSchema {
//        return .object(
//            properties: [
//                "id": .string,
//                "type": .string(allowedValues: [AnyCodable(jsonType)]),
//                "attributes": .object(
//                    properties: attributes
//                ),
//                "relationships": .object(
//                    properties: relationships.mapValues { JSONSchema.reference($0) }
//                )
//            ]
//        )
//    }
//}

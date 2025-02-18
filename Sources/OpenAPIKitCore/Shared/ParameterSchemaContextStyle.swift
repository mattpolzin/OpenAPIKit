//
//  ParameterSchemaContextStyle.swift
//  
//
//  Created by Mathew Polzin on 12/18/22.
//

extension Shared {
    public enum ParameterSchemaContextStyle: String, CaseIterable, Codable, Sendable {
        case form
        case simple
        case matrix
        case label
        case spaceDelimited
        case pipeDelimited
        case deepObject
    }
}

//
//  ParameterSchemaContextStyle.swift
//  
//
//  Created by Mathew Polzin on 12/18/22.
//

extension OpenAPI.Parameter.SchemaContext {
    public enum Style: String, CaseIterable, Codable, Sendable {
        case form
        case simple
        case matrix
        case label
        case spaceDelimited
        case pipeDelimited
        case deepObject
        case cookie
    }
}

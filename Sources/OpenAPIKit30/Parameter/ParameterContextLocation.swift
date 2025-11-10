//
//  ParameterContextLocation.swift
//  
//
//  Created by Mathew Polzin on 12/24/22.
//

import OpenAPIKitCore

extension OpenAPI.Parameter.Context {
    public enum Location: String, CaseIterable, Codable {
        case query
        case header
        case path
        case cookie
    }
}

extension OpenAPI.Parameter.Context.Location: Validatable {}

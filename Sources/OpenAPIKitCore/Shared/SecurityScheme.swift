//
//  SecurityScheme.swift
//  
//
//  Created by Mathew Polzin on 12/18/22.
//

extension Shared {
    public enum SecuritySchemeLocation: String, Codable, Equatable {
        case query
        case header
        case cookie
    }
}

extension Shared.SecuritySchemeLocation: Validatable {}

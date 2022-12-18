//
//  SecurityScheme.swift
//  
//
//  Created by Mathew Polzin on 12/18/22.
//

public enum SecuritySchemeLocation: String, Codable, Equatable {
    case query
    case header
    case cookie
}

extension SecuritySchemeLocation: Validatable {}

//
//  ParameterContextLocation.swift
//  
//
//  Created by Mathew Polzin on 12/24/22.
//

extension Shared {
    public enum ParameterContextLocation: String, CaseIterable, Codable {
        case query
        case header
        case path
        case cookie
    }
}

extension Shared.ParameterContextLocation: Validatable {}

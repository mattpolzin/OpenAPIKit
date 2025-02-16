//
//  JSONSchemaPermissions.swift
//  
//
//  Created by Mathew Polzin on 12/17/22.
//

extension Shared {
    public enum JSONSchemaPermissions: String, Codable, Sendable {
        case readOnly
        case writeOnly
        case readWrite
    }
}

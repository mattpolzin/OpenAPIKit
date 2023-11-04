//
//  _CoreReExport.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

@_exported import struct OpenAPIKitCore.AnyCodable
@_exported import struct OpenAPIKitCore.CodingPathError
@_exported import enum OpenAPIKitCore.Either
@_exported import protocol OpenAPIKitCore.OpenAPIError
@_exported import struct OpenAPIKitCore.OrderedDictionary
@_exported import struct OpenAPIKitCore.URLTemplate

import OpenAPIKitCore

public extension OpenAPI {
    typealias HttpMethod = OpenAPIKitCore.Shared.HttpMethod
    typealias ContentType = OpenAPIKitCore.Shared.ContentType
    typealias Error = OpenAPIKitCore.Error
    typealias Warning = OpenAPIKitCore.Warning
    typealias Path = OpenAPIKitCore.Shared.Path
    typealias ComponentKey = OpenAPIKitCore.Shared.ComponentKey
    typealias Discriminator = OpenAPIKitCore.Shared.Discriminator
    typealias OAuthFlows = OpenAPIKitCore.Shared.OAuthFlows
    typealias CallbackURL = OpenAPIKitCore.Shared.CallbackURL
}

public extension OpenAPI.SecurityScheme {
    typealias Location = OpenAPIKitCore.Shared.SecuritySchemeLocation
}

public extension OpenAPI.Parameter.Context {
    typealias Location = OpenAPIKitCore.Shared.ParameterContextLocation
}

public extension OpenAPI.Parameter.SchemaContext {
    typealias Style = OpenAPIKitCore.Shared.ParameterSchemaContextStyle
}

public extension OpenAPI.Response {
    typealias StatusCode = OpenAPIKitCore.Shared.ResponseStatusCode
}

public extension JSONSchema {
    typealias Permissions = OpenAPIKitCore.Shared.JSONSchemaPermissions
}

public extension JSONTypeFormat {
    typealias AnyFormat = OpenAPIKitCore.Shared.AnyFormat
    typealias BooleanFormat = OpenAPIKitCore.Shared.BooleanFormat
    typealias ObjectFormat = OpenAPIKitCore.Shared.ObjectFormat
    typealias ArrayFormat = OpenAPIKitCore.Shared.ArrayFormat
    typealias NumberFormat = OpenAPIKitCore.Shared.NumberFormat
    typealias IntegerFormat = OpenAPIKitCore.Shared.IntegerFormat
}

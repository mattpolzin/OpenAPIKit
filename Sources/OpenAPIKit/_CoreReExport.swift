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
    typealias HttpMethod = OpenAPIKitCore.HttpMethod
    typealias ContentType = OpenAPIKitCore.ContentType
    typealias Error = OpenAPIKitCore.Error
    typealias Warning = OpenAPIKitCore.Warning
    typealias Path = OpenAPIKitCore.Path
    typealias ComponentKey = OpenAPIKitCore.ComponentKey
    typealias Discriminator = OpenAPIKitCore.Discriminator
    typealias ExternalDocumentation = OpenAPIKitCore.ExternalDocumentation
}

public extension JSONSchema {
    typealias Permissions = OpenAPIKitCore.JSONSchemaPermissions
}

public extension JSONTypeFormat {
    typealias AnyFormat = OpenAPIKitCore.AnyFormat
    typealias BooleanFormat = OpenAPIKitCore.BooleanFormat
    typealias ObjectFormat = OpenAPIKitCore.ObjectFormat
    typealias ArrayFormat = OpenAPIKitCore.ArrayFormat
    typealias NumberFormat = OpenAPIKitCore.NumberFormat
    typealias IntegerFormat = OpenAPIKitCore.IntegerFormat
    typealias StringFormat = OpenAPIKitCore.StringFormat
}

//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

/// What the spec calls the "Components Object".
/// This is a place to put reusable components to
/// be referenced from other parts of the spec.
public struct OpenAPIComponents: Equatable, Encodable, ReferenceRoot {
    public static var refName: String { return "components" }

    public let schemas: SchemasDict
    //    public let responses:
    public let parameters: ParametersDict
    //    public let examples:
    //    public let requestBodies:
    //    public let headers:
    //    public let headers:
    //    public let securitySchemas:
    //    public let links:
    //    public let callbacks:

    public init(schemas: [String: SchemasDict.Value], parameters: [String: ParametersDict.Value]) {
        self.schemas = SchemasDict(schemas)
        self.parameters = ParametersDict(parameters)
    }

    public enum SchemasName: RefName {
        public static var refName: String { return "schemas" }
    }

    public typealias SchemasDict = RefDict<OpenAPIComponents, SchemasName, JSONSchemaObject>

    public enum ParametersName: RefName {
        public static var refName: String { return "parameters" }
    }

    public typealias ParametersDict = RefDict<OpenAPIComponents, ParametersName, OpenAPIPathItem.PathProperties.Parameter>
}

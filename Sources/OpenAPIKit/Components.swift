//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    /// What the spec calls the "Components Object".
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    public struct Components: Equatable, Codable, ReferenceRoot {
        public static var refName: String { return "components" }

        public let schemas: SchemasDict
        //    public let responses:
        public let parameters: ParametersDict
        public let examples: ExamplesDict
        //    public let requestBodies:
        public let headers: HeadersDict
        //    public let securitySchemas:
        //    public let links:
        //    public let callbacks:

        public init(schemas: [String: SchemasDict.Value],
                    parameters: [String: ParametersDict.Value],
                    examples: [String: ExamplesDict.Value],
                    headers: [String: HeadersDict.Value]) {
            self.schemas = SchemasDict(schemas)
            self.parameters = ParametersDict(parameters)
            self.examples = ExamplesDict(examples)
            self.headers = HeadersDict(headers)
        }

        public static var noComponents: Components {
            return .init(schemas: [:],
                         parameters: [:],
                         examples: [:],
                         headers: [:])
        }

        public enum SchemasName: RefName {
            public static var refName: String { return "schemas" }
        }

        public typealias SchemasDict = RefDict<Components, SchemasName, JSONSchema>

        public enum ParametersName: RefName {
            public static var refName: String { return "parameters" }
        }

        public typealias ParametersDict = RefDict<Components, ParametersName, PathItem.Parameter>

        public enum ExamplesName: RefName {
            public static var refName: String { return "examples" }
        }

        public typealias ExamplesDict = RefDict<Components, ExamplesName, OpenAPI.Example>

        public enum HeadersName: RefName {
            public static var refName: String { return "headers" }
        }

        public typealias HeadersDict = RefDict<Components, HeadersName, Header>
    }
}

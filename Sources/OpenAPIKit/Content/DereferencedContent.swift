//
//  DereferencedContent.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

@dynamicMemberLookup
public struct DereferencedContent: Equatable {
    private let content: OpenAPI.Content
    public let schema: DereferencedJSONSchema
    public let examples: OrderedDictionary<String, OpenAPI.Example>?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Content, T>) -> T {
        return content[keyPath: path]
    }

    public init(content: OpenAPI.Content, resolvingIn components: OpenAPI.Components) throws {
        self.schema = try DereferencedJSONSchema(
            jsonSchema: try components.forceDereference(content.schema),
            resolvingIn: components
        )
    }
}

//
//  JSONSchemaSimpleContexts.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

extension Shared {
    /// The context that only applies to `.reference` schemas.
    public struct ReferenceContext: Equatable {
        public let required: Bool

        public init(required: Bool = true) {
            self.required = required
        }

        public func requiredContext() -> ReferenceContext {
            return .init(required: true)
        }

        public func optionalContext() -> ReferenceContext {
            return .init(required: false)
        }
    }
}

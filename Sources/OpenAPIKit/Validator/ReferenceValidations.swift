//
//  ReferenceValidations.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

import OpenAPIKitCore

extension Validation {
    internal enum References {
        /// Create a validation that all non-external OpenAPI references of the
        /// given type that point at the Components Object are found in the
        /// document's components dictionary. You can choose whether an
        /// internal reference to somewhere other than the components
        /// dictionary should pass or fail.
        internal static func referencesAreValid<ReferenceType: ComponentDictionaryLocatable>(ofType type: ReferenceType.Type, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<ReferenceType>> {
            .init(
                description: "OpenAPI \(String(describing: type)) reference can be found in components/\(ReferenceType.openAPIComponentsKey)",
                check: { context in
                    guard case let .internal(internalReference) = context.subject.jsonReference else {
                        // don't make assertions about external references
                        return true
                    }

                    guard case .component = internalReference else {
                        // we can't currently resolve non-components internal
                        // references, but we can either consider them
                        // implicitly valid or not depending on the use-case:
                        return !requireComponents
                    }
                    return context.document.components.contains(internalReference)
                }
            )
        }

        internal static func schemaReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<JSONSchema>> {
            referencesAreValid(ofType: JSONSchema.self, mustPointToComponents: requireComponents)
        }

        internal static func jsonSchemaReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<JSONSchema> {
            .init(
                description: "JSONSchema reference can be found in components/schemas",
                check: { context in
                    guard case let .internal(internalReference) = context.subject.reference else {
                        // don't make assertions about external references
                        return true
                    }

                    guard case .component = internalReference else {
                        // we can't currently resolve non-components internal
                        // references, but we can either consider them
                        // implicitly valid or not depending on the use-case:
                        return !requireComponents
                    }
                    return context.document.components.contains(internalReference)
                }
            )
        }

        internal static func responseReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Response>> {
            referencesAreValid(ofType: OpenAPI.Response.self, mustPointToComponents: requireComponents)
        }

        internal static func parameterReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Parameter>> {
            referencesAreValid(ofType: OpenAPI.Parameter.self, mustPointToComponents: requireComponents)
        }

        internal static func exampleReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Example>> {
            referencesAreValid(ofType: OpenAPI.Example.self, mustPointToComponents: requireComponents)
        }

        internal static func requestReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Request>> {
            referencesAreValid(ofType: OpenAPI.Request.self, mustPointToComponents: requireComponents)
        }

        internal static func headerReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Header>> {
            referencesAreValid(ofType: OpenAPI.Header.self, mustPointToComponents: requireComponents)
        }

        internal static func linkReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Link>> {
            referencesAreValid(ofType: OpenAPI.Link.self, mustPointToComponents: requireComponents)
        }

        internal static func callbacksReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Callbacks>> {
            referencesAreValid(ofType: OpenAPI.Callbacks.self, mustPointToComponents: requireComponents)
        }

        internal static func pathItemReferencesAreValid(mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.PathItem>> {
            referencesAreValid(ofType: OpenAPI.PathItem.self, mustPointToComponents: requireComponents)
        }
    }
}

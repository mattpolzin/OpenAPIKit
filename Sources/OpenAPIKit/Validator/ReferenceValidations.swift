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
        /// dictionary should pass or fail. You can also choose whether
        /// external references should fail or pass.
        internal static func referencesAreValid<ReferenceType: ComponentDictionaryLocatable>(ofType type: ReferenceType.Type, named name: String, mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<ReferenceType>> {
            let requireInternalAddendum = if requireInternal { " points to this document and" } else { "" }

            return .init(
                description: "\(name) reference\(requireInternalAddendum) can be found in components/\(ReferenceType.openAPIComponentsKey)",
                check: { context in
                    guard case let .internal(internalReference) = context.subject.jsonReference else {
                        // don't make assertions about external references other than if we are requiring references to be internal
                        return !requireInternal
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

        internal static func schemaReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<JSONSchema>> {
            referencesAreValid(ofType: JSONSchema.self, named: "JSONSchema", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func jsonSchemaReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<JSONSchema> {
            let requireInternalAddendum = if requireInternal { " points to this document and" } else { "" }

            return .init(
                description: "JSONSchema reference\(requireInternalAddendum) can be found in components/schemas",
                check: { context in
                    guard case let .internal(internalReference) = context.subject.reference  else {
                        // don't make assertions about external references
                        return !requireInternal
                    }

                    guard case .component = internalReference else {
                        // we can't currently resolve non-components internal
                        // references, but we can either consider them
                        // implicitly valid or not depending on the use-case:
                        return !requireComponents
                    }
                    return context.document.components.contains(internalReference)
                },
                when: \.reference != nil
            )
        }

        internal static func responseReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Response>> {
            referencesAreValid(ofType: OpenAPI.Response.self, named: "Response", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func parameterReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Parameter>> {
            referencesAreValid(ofType: OpenAPI.Parameter.self, named: "Parameter", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func exampleReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Example>> {
            referencesAreValid(ofType: OpenAPI.Example.self, named: "Example", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func requestReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Request>> {
            referencesAreValid(ofType: OpenAPI.Request.self, named: "Request", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func headerReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Header>> {
            referencesAreValid(ofType: OpenAPI.Header.self, named: "Header", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func linkReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Link>> {
            referencesAreValid(ofType: OpenAPI.Link.self, named: "Link", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func callbacksReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.Callbacks>> {
            referencesAreValid(ofType: OpenAPI.Callbacks.self, named: "Callbacks", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }

        internal static func pathItemReferencesAreValid(mustBeInternal requireInternal: Bool, mustPointToComponents requireComponents: Bool) -> Validation<OpenAPI.Reference<OpenAPI.PathItem>> {
            referencesAreValid(ofType: OpenAPI.PathItem.self, named: "PathItem", mustBeInternal: requireInternal, mustPointToComponents: requireComponents)
        }
    }
}

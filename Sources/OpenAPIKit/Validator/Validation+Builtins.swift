//
//  Validation+Builtins.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

import OpenAPIKitCore

extension Validation {
    // MARK: - Optionally added with `Validator.validating()`

    /// Validate the OpenAPI Document has at least one path in its
    /// `PathItem.Map`.
    ///
    /// The OpenAPI Specification does not require that the document
    /// contain any paths for [security reasons](https://spec.openapis.org/oas/v3.2.0.html#security-filtering)
    /// or even because it only contains webhooks, but authors may still
    /// want to protect against an empty `PathItem.Map` in some cases.
    ///
    /// - Important: This is not an included validation by default.
    public static var documentContainsPaths: Validation<OpenAPI.Document> {
        .init(
            description: "Document contains at least one path",
            check: \.paths.count > 0
        )
    }

    /// Validate the OpenAPI Document's `PathItems` all have at least
    /// one operation.
    ///
    /// The OpenAPI Specification does not require that path items
    /// contain any operations for [security reasons](https://spec.openapis.org/oas/v3.2.0.html#security-filtering)
    /// but documentation that is public in nature might only ever have
    /// a `PathItem` with no operations in error.
    ///
    /// - Important: This is not an included validation by default.
    public static var pathsContainOperations: Validation<OpenAPI.PathItem> {
        .init(
            description: "Paths contain at least one operation",
            check: \.endpoints.count > 0
        )
    }

    /// Validate the OpenAPI Document's `JSONSchemas` all have at least
    /// one defining characteristic.
    ///
    /// The JSON Schema Specification does not require that components
    /// have any defining characteristics. An "empty" schema component can
    /// be written as follows:
    ///
    ///     {
    ///     }
    ///
    /// It is reasonable, however, to want to validate that all schema components
    /// are non-empty and therefore offer some value to the consumer/reader of
    /// the OpenAPI documentation beyond just "this property exists."
    ///
    /// - Note: A sneaky way for the empty object to get into documentation is
    ///     by putting a property name in a parent object's `required` array
    ///     without adding that property to the `properties` map.
    ///
    /// - Important: This is not an included validation by default.
    public static var schemaComponentsAreDefined: Validation<JSONSchema> {
        .init(
            description: "JSON Schema components have defining characteristics (i.e. they are not just the empty schema component: `{}`) [Note that one way to end up with empty schema components is by having property names in an object's `required` array that are not defined in that object's `properties` map]",
            check: \.subject.isEmpty == false
        )
    }

    /// Validate that any `Parameters` in the path of any endpoint are documented.
    /// In other words, if a path contains variables (i.e. `"{variable}"`) then there are
    /// corresponding `parameters` entries in the `PathItem` or `Operation` for
    /// each endpoint.
    ///
    /// In order to gain easy access to both the path (where the variable placeholders live)
    /// and the parameter definitions, this validation runs once per document and performs a
    /// loop over each endpoint in the document.
    ///
    /// - Important: This validation does not assert that all path item references are valid and
    ///     can be found. Invalid or missing references will be skipped over.
    ///
    /// - Important: This is not an included validation by default.
    public static var pathParametersAreDefined: Validation<OpenAPI.PathItem.Map> {
        .init(
            check: { context in
                var errors = [ValidationError]()

                for (path, item) in context.subject {
                    guard let pathItem = context.document.components[item] else { continue }
                    let variablesInPath = path.components
                        .lazy
                        .filter { $0.first == "{" && $0.last == "}" }
                        .map { String($0.dropFirst().dropLast()) }

                    let paramsInPathItem = Array(
                        pathItem.parameters
                        .lazy
                        .compactMap { context.document.components[$0] }
                        .map { $0.name }
                    )

                    for endpoint in pathItem.endpoints {
                        let paramsInOperation = Array(
                            endpoint.operation.parameters
                            .lazy
                            .compactMap { context.document.components[$0]}
                            .map { $0.name }
                        )

                        let missingParamDefs = Array(
                            variablesInPath
                            .filter { !((paramsInPathItem + paramsInOperation).contains($0)) }
                        )

                        if !missingParamDefs.isEmpty {
                            let codingPath = context.codingPath + [
                                path.rawValue,
                                endpoint.method.rawValue
                            ].map(Validator.CodingKey.init(stringValue:))

                            errors.append(
                                .init(
                                    reason: "The following path parameters were not defined in the Path Item or Operation `parameters`: \(missingParamDefs)",
                                    at: codingPath
                                )
                            )
                        }
                    }
                }

                return errors
            }
        )
    }

    /// Validate that all Server Objects define all of the variables found in their URL Templates.
    ///
    /// For example, a server URL Template of `{scheme}://website.com/{path}` would
    /// fail this validation if either "scheme" or "path" were not found in the Server Object's
    /// `variables` dictionary.
    ///
    /// - Important: This is not an included validation by default.
    public static var serverVariablesAreDefined: Validation<OpenAPI.Server> {
        .init(
            check: { context in
                let missingVariables = context.subject.urlTemplate.variables
                    .filter { !context.subject.variables.contains(key: $0) }

                return missingVariables.map { variableName in
                    ValidationError(
                        reason: "Server Object does not define the variable '\(variableName)' that is found in the `urlTemplate` '\(context.subject.urlTemplate.rawValue)'",
                        at: context.codingPath
                    )
                }
            }
        )
    }

    /// Validate the OpenAPI Document's `Operations` all have at least
    /// one response.
    ///
    /// The OpenAPI Specification does not require that Responses Objects
    /// contain at least one response but you may wish to validate that all 
    /// operations contain at least one response in your own API.
    ///
    /// The specification recommends that if there is only one response then
    /// it be a successful response but this validation does not require that.
    ///
    /// - Important: This is not an included validation by default.
    public static var operationsContainResponses: Validation<OpenAPI.Operation> {
        .init(
            description: "Operations contain at least one response",
            check: \.responses.count > 0
        )
    }

    /// Validate the OpenAPI Document's `Links` with operationIds refer to
    /// Operations that exist in the document.
    ///
    /// This validation ensures that Link Objects using operationIds have corresponding
    /// Operations in the document that have those IDs.
    ///
    /// - Important: This is not an included validation by default.
    public static var linkOperationsExist: Validation<OpenAPI.Link> {
        .init(
            description: "Links with operationIds have corresponding Operations",
            check: { context in
                guard case let .b(operationId) = context.subject.operation else {
                    // don't make assertions about Links that don't have operationIds
                    return true
                }
                
                // Collect all operation IDs from the document
                let operationIds = context.document.allOperationIds
                
                return operationIds.contains(operationId)
            }
        )
    }

    /// Validate that all OpenAPI JSONSchema references are internal and found
    /// in the document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `schemaReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var schemaReferencesFoundInComponents: Validation<OpenAPI.Reference<JSONSchema>> {
        References.schemaReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all JSONSchema references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `jsonSchemaReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var jsonSchemaReferencesFoundInComponents: Validation<JSONSchema> {
        References.jsonSchemaReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Response references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `responseReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var responseReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Response>> {
        References.responseReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Parameter references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `parameterReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var parameterReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Parameter>> {
        References.parameterReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Example references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `exampleReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var exampleReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Example>> {
        References.exampleReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Request references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `requestReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var requestReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Request>> {
        References.requestReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Header references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `headerReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var headerReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Header>> {
        References.headerReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Link references are internal and found in the document's
    /// components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `linkReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var linkReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Link>> {
        References.linkReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all Callbacks references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `callbacksReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var callbacksReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.Callbacks>> {
        References.callbacksReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    /// Validate that all PathItem references are internal and found in the
    /// document's components dictionary.
    ///
    /// - See also: The similar but distinct default-on validation
    ///             `pathItemReferencesAreValid`. 
    ///
    /// - Important: This is not an included in validation by default.
    ///
    public static var pathItemReferencesFoundInComponents: Validation<OpenAPI.Reference<OpenAPI.PathItem>> {
        References.pathItemReferencesAreValid(mustBeInternal: true, mustPointToComponents: true)
    }

    // MARK: - Included with `Validator()` by default

    // You can start with no validations (not even the defaults below)
    // by calling `Validator.blank`.

    /// Validate that the OpenAPI Document's `Tags` all have unique names.
    ///
    /// The OpenAPI Specification requires that tag names on the Document
    /// [are unique](https://spec.openapis.org/oas/v3.2.0.html#openapi-object).
    ///
    /// - Important: This is included in validation by default.
    public static var documentTagNamesAreUnique: Validation<OpenAPI.Document> {
        .init(
            description: "The names of Tags in the Document are unique",
            check: take(\.tags) { maybeTags in
                guard let tags = maybeTags else { return true }

                return Set(tags.map { $0.name }).count == tags.count
            }
        )
    }

    /// Validate that all OpenAPI Path Items have no duplicate parameters defined
    /// within them.
    ///
    /// A Path Item Parameter's identity is defined as the pairing of its `name` and
    /// `location`.
    ///
    /// The OpenAPI Specification requires that these parameters [are unique](https://spec.openapis.org/oas/v3.2.0.html#path-item-object).
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var pathItemParametersAreUnique: Validation<OpenAPI.PathItem> {
        .init(
            description: "Path Item parameters are unique (identity is defined by the 'name' and 'location')",
            check: { parametersAreUnique($0.subject.parameters, components: $0.document.components) },
            when: \.parameters.count > 0
        )
    }

    /// Validate that all OpenAPI Operations have no duplicate parameters defined
    /// within them.
    ///
    /// An Operation's Parameter's identity is defined as the pairing of its `name` and
    /// `location`.
    ///
    /// The OpenAPI Specification requires that these parameters [are unique](https://spec.openapis.org/oas/v3.2.0.html#operation-object).
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var operationParametersAreUnique: Validation<OpenAPI.Operation> {
        .init(
            description: "Operation parameters are unique (identity is defined by the 'name' and 'location')",
            check: { parametersAreUnique($0.subject.parameters, components: $0.document.components) },
            when: \.parameters.count > 0
        )
    }

    /// Validate that `querystring` parameters are unique and do not coexist
    /// with `query` parameters within a Path Item's effective operation
    /// parameters.
    ///
    /// OpenAPI 3.2.0 requires that a `querystring` parameter
    /// [must not appear more than once and must not appear in the same operation
    /// as any `query` parameters](https://spec.openapis.org/oas/v3.2.0.html#parameter-locations).
    ///
    /// - Important: This is included in validation by default.
    public static var querystringParametersAreCompatible: Validation<OpenAPI.PathItem> {
        .init(
            description: "Querystring parameters are unique and do not coexist with query parameters",
            check: { context in
                let pathParameters = resolvedParameters(context.subject.parameters, components: context.document.components)
                let pathSummary = parameterLocationSummary(pathParameters)
                let pathParametersPath = context.codingPath + [Validator.CodingKey.init(stringValue: "parameters")]
                var errors = [ValidationError]()

                if pathSummary.querystringCount > 1 {
                    errors.append(
                        ValidationError(
                            reason: "Path Item parameters must not contain more than one `querystring` parameter",
                            at: pathParametersPath
                        )
                    )
                }

                if pathSummary.querystringCount > 0 && pathSummary.queryCount > 0 {
                    errors.append(
                        ValidationError(
                            reason: "Path Item parameters must not mix `querystring` and `query` parameter locations",
                            at: pathParametersPath
                        )
                    )
                }

                for endpoint in context.subject.endpoints {
                    let operationParameters = resolvedParameters(endpoint.operation.parameters, components: context.document.components)
                    let operationSummary = parameterLocationSummary(operationParameters)
                    let operationParametersPath = context.codingPath + [
                        Validator.CodingKey.init(stringValue: codingPathKey(for: endpoint.method)),
                        Validator.CodingKey.init(stringValue: "parameters")
                    ]

                    if operationSummary.querystringCount > 1 {
                        errors.append(
                            ValidationError(
                                reason: "Operation parameters must not contain more than one `querystring` parameter",
                                at: operationParametersPath
                            )
                        )
                    }

                    if operationSummary.querystringCount > 0 && operationSummary.queryCount > 0 {
                        errors.append(
                            ValidationError(
                                reason: "Operation parameters must not mix `querystring` and `query` parameter locations",
                                at: operationParametersPath
                            )
                        )
                    }

                    if pathSummary.querystringCount <= 1 &&
                        operationSummary.querystringCount <= 1 &&
                        pathSummary.querystringCount + operationSummary.querystringCount > 1 {
                        errors.append(
                            ValidationError(
                                reason: "Operation parameters must not contain more than one `querystring` parameter, including inherited Path Item parameters",
                                at: operationParametersPath
                            )
                        )
                    }

                    if !(pathSummary.querystringCount > 0 && pathSummary.queryCount > 0) &&
                        !(operationSummary.querystringCount > 0 && operationSummary.queryCount > 0) &&
                        pathSummary.querystringCount + operationSummary.querystringCount > 0 &&
                        pathSummary.queryCount + operationSummary.queryCount > 0 {
                        errors.append(
                            ValidationError(
                                reason: "Operation parameters must not mix `querystring` and `query` parameter locations, including inherited Path Item parameters",
                                at: operationParametersPath
                            )
                        )
                    }
                }

                return errors
            }
        )
    }

    /// Validate that all OpenAPI Operation Ids are unique across the whole Document.
    ///
    /// The OpenAPI Specification requires that Operation Ids [are unique](https://spec.openapis.org/oas/v3.2.0.html#operation-object).
    ///
    /// - Important: This validation does not assert that all path references are valid and found in the
    ///     components for the document. It skips over missing path items.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var operationIdsAreUnique: Validation<OpenAPI.Document> {
        .init(
            description: "All Operation Ids in Document are unique",
            check: { context in
                let operationIds = context.subject.paths.values
                    .flatMap { context.subject.components[$0]?.endpoints ?? [] }
                    .compactMap { $0.operation.operationId }
                return Set(operationIds).count == operationIds.count
            }
        )
    }

    /// Validate that all OpenAPI JSONSchema components references are found in
    /// the document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var schemaReferencesAreValid: Validation<OpenAPI.Reference<JSONSchema>> {
        References.schemaReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all JSONSchema components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var jsonSchemaReferencesAreValid: Validation<JSONSchema> {
        References.jsonSchemaReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Response components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var responseReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Response>> {
        References.responseReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Parameter components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var parameterReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Parameter>> {
        References.parameterReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Example components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var exampleReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Example>> {
        References.exampleReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Request components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var requestReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Request>> {
        References.requestReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Header components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var headerReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Header>> {
        References.headerReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Link components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var linkReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Link>> {
        References.linkReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all Callbacks components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var callbacksReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.Callbacks>> {
        References.callbacksReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }

    /// Validate that all PathItem components references are found in the
    /// document's components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var pathItemReferencesAreValid: Validation<OpenAPI.Reference<OpenAPI.PathItem>> {
        References.pathItemReferencesAreValid(mustBeInternal: false, mustPointToComponents: false)
    }
    
    /// Validate that `enum` must not be empty in the document's
    /// Server Variable.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var serverVariableEnumIsValid: Validation<OpenAPI.Server.Variable> {
        .init(
            description: "Server Variable's enum is either not defined or is non-empty (if defined).",
            check: { context in
                guard let `enum` = context.subject.`enum` else { return true }
                return `enum`.isEmpty == false
            }
        )
    }

    /// Validate that `default` must exist in the enum values in the document's
    /// Server Variable, if such values (enum) are defined.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var serverVariableDefaultExistsInEnum : Validation<OpenAPI.Server.Variable> {
        .init(
            description: "Server Variable's default must exist in enum, if enum is defined.",
            check: { context in
                guard let `enum` = context.subject.`enum` else { return true }
                return `enum`.contains(context.subject.`default`)
            }
        )
    }

    /// Validate the OpenAPI Document's `Parameter`s all have styles that are
    /// compatible with their locations per the table found at
    /// https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.2.0.md#style-values
    ///
    /// - Important: This is included in validation by default.
    public static var parameterStyleAndLocationAreCompatible: Validation<OpenAPI.Parameter> {
        .init(
            description: "Parameter styles are all compatible with their locations",
            check: all(
                Validation<OpenAPI.Parameter>(
                    description: "the matrix style can only be used for the path location",
                    check: \.context.location == .path,
                    when: \.schemaStyle == .matrix
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the label style can only be used for the path location",
                    check: \.context.location == .path,
                    when: \.schemaStyle == .label
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the simple style can only be used for the path and header locations",
                    check: \.context.location == .path || \.context.location == .header,
                    when: \.schemaStyle == .simple
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the form style can only be used for the query and cookie locations",
                    check: \.context.location == .query || \.context.location == .cookie,
                    when: \.schemaStyle == .form
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the spaceDelimited style can only be used for the query location",
                    check: \.context.location == .query,
                    when: \.schemaStyle == .spaceDelimited
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the pipeDelimited style can only be used for the query location",
                    check: \.context.location == .query,
                    when: \.schemaStyle == .pipeDelimited
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the deepObject style can only be used for the query location",
                    check: \.context.location == .query,
                    when: \.schemaStyle == .deepObject
                ),
                Validation<OpenAPI.Parameter>(
                    description: "the cookie style can only be used for the cookie location",
                    check: \.context.location == .cookie,
                    when: \.schemaStyle == .cookie
                )
            )
        )
    }
}

/// Used by both the Path Item parameter check and the
/// Operation parameter check in the default validations.
fileprivate func parametersAreUnique(_ parameters: OpenAPI.Parameter.Array, components: OpenAPI.Components) -> Bool {
    let foundParameters = resolvedParameters(parameters, components: components)

    let identities = foundParameters.map { OpenAPI.Parameter.ParameterIdentity(name: $0.name, location: $0.location) }

    return Set(identities).count == foundParameters.count
}

fileprivate func resolvedParameters(_ parameters: OpenAPI.Parameter.Array, components: OpenAPI.Components) -> [OpenAPI.Parameter] {
    parameters.compactMap { try? components.lookup($0) }
}

fileprivate struct ParameterLocationSummary {
    let queryCount: Int
    let querystringCount: Int
}

fileprivate func parameterLocationSummary(_ parameters: [OpenAPI.Parameter]) -> ParameterLocationSummary {
    .init(
        queryCount: parameters.filter { $0.location == .query }.count,
        querystringCount: parameters.filter { $0.location == .querystring }.count
    )
}

fileprivate func codingPathKey(for method: OpenAPI.HttpMethod) -> String {
    switch method {
    case .builtin(let builtin):
        return builtin.rawValue.lowercased()
    case .other(let other):
        return other
    }
}

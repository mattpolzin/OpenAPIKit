//
//  Components+JSONReference.swift
//  
//
//  Created by Mathew Polzin on 3/30/20.
//

import OpenAPIKitCore

extension OpenAPI.Components {
    /// Check if the `Components` contains the given reference or not.
    ///
    /// This may in some cases mean that the `Components` entry for the given
    /// reference is itself another reference (e.g. entries in the `responses`
    /// dictionary are allowed to be references).
    ///
    /// If you want a non-throwing alternative, you can pull a
    /// `JSONReference.InternalReference` out of the `reference` and pass that
    /// to `contains` instead.
    ///
    /// - Throws: If the given reference cannot be checked against `Components`
    ///     then this method will throw `ReferenceError`. This will occur when
    ///     the given reference is a remote file reference.
    public func contains<ReferenceType: ComponentDictionaryLocatable>(_ reference: OpenAPI.Reference<ReferenceType>) throws -> Bool {

        return try contains(reference.jsonReference)
    }

    /// Check if the `Components` contains the given reference or not.
    ///
    /// This may in some cases mean that the `Components` entry for the given
    /// reference is itself another reference (e.g. entries in the `responses`
    /// dictionary are allowed to be references).
    ///
    /// If you want a non-throwing alternative, you can pull a
    /// `JSONReference.InternalReference` out of your `reference` and pass that
    /// to `contains` instead.
    ///
    /// - Throws: If the given reference cannot be checked against `Components`
    ///     then this method will throw `ReferenceError`. This will occur when
    ///     the given reference is a remote file reference.
    public func contains<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) throws -> Bool {
        guard case .internal(let localReference) = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }

        return contains(localReference)
    }

    /// Check if the `Components` contains the given internal reference or not.
    ///
    /// This may in some cases mean that the `Components` entry for the given
    /// reference is itself another reference (e.g. entries in the `responses`
    /// dictionary are allowed to be references).
    public func contains<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) -> Bool {
        switch ReferenceType.openAPIComponentsKeyPath {
        case .a(let directPath):
            return reference.name
                .flatMap(OpenAPI.ComponentKey.init(rawValue:))
                .map { self[keyPath: directPath].contains(key: $0) }
                ?? false
        case .b(let referencePath):
            return reference.name
                .flatMap(OpenAPI.ComponentKey.init(rawValue:))
                .map { self[keyPath: referencePath].contains(key: $0) }
                ?? false
        }
    }

    /// Retrieve a referenced item from the `Components` or just return the
    /// item directly depending on what value the `Either` contains.
    ///
    /// This function will follow subsequent refernences found within the
    /// `Components` as long as no cycles are encountered. If a cycle is
    /// encountered or a reference to a part of the document outside of the
    /// `Components` is encountered then the function returns `nil`.
    ///
    /// If you want a throwing lookup, use the `lookup()` method.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ maybeReference: Either<OpenAPI.Reference<ReferenceType>, ReferenceType>) -> ReferenceType? {
        switch maybeReference {
        case .a(let reference):
            return self[reference]
        case .b(let value):
            return value
        }
    }

    /// Retrieve item referenced from the `Components`.
    ///
    /// This function will follow subsequent refernences found within the
    /// `Components` as long as no cycles are encountered. If a cycle is
    /// encountered or a reference to a part of the document outside of the
    /// `Components` is encountered then the function returns `nil`.
    ///
    /// If you want a throwing lookup, use the `lookup()` method.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ reference: OpenAPI.Reference<ReferenceType>) -> ReferenceType? {

        return self[reference.jsonReference]
    }

    /// Retrieve item referenced from the `Components`.
    ///
    /// This function will follow subsequent refernences found within the
    /// `Components` as long as no cycles are encountered. If a cycle is
    /// encountered or a reference to a part of the document outside of the
    /// `Components` is encountered then the function returns `nil`.
    ///
    /// If you want a throwing lookup, use the `lookup()` method.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) -> ReferenceType? {
        guard case .internal(let localReference) = reference else {
            return nil
        }

        return self[localReference]
    }

    /// Retrieve item referenced from the `Components`.
    ///
    /// This function will follow subsequent refernences found within the
    /// `Components` as long as no cycles are encountered. If a cycle is
    /// encountered or a reference to a part of the document outside of the
    /// `Components` is encountered then the function returns `nil`.
    ///
    /// If you want a throwing lookup, use the `lookup()` method.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) -> ReferenceType? {
        return try? lookup(reference)
    }

    /// Pass a reference to a component.
    /// `lookupOnce()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// The value may itself be a reference. If you want to follow all
    /// references until the ReferenceType is found, use `lookup()`.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// If the `OpenAPI.Reference` has a `summary` or `description` then the referenced
    /// object will have its `summary` and/or `description` overridden by that of the reference.
    /// This only applies if the referenced object would normally have a summary/description.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)`
    public func lookupOnce<ReferenceType: ComponentDictionaryLocatable>(_ reference: OpenAPI.Reference<ReferenceType>) throws -> Either<OpenAPI.Reference<ReferenceType>, ReferenceType> {
        let value = try lookupOnce(reference.jsonReference)

        switch value {
        case .a(let reference):
            return .a(
                reference
                    .overriddenNonNil(summary: reference.summary)
                    .overriddenNonNil(description: reference.description)
            )

        case .b(let direct):
            return .b(
                direct
                  .overriddenNonNil(summary: reference.summary)
                  .overriddenNonNil(description: reference.description)
            )
        }
    }

    /// Pass a reference to a component.
    /// `lookup()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// If the `OpenAPI.Reference` has a `summary` or `description` then the referenced
    /// object will have its `summary` and/or `description` overridden by that of the reference.
    /// This only applies if the referenced object would normally have a summary/description.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)` or
    ///     `ReferenceCycleError`
    public func lookup<ReferenceType: ComponentDictionaryLocatable>(_ reference: OpenAPI.Reference<ReferenceType>) throws -> ReferenceType {

        return try lookup(reference.jsonReference)
            .overriddenNonNil(summary: reference.summary)
            .overriddenNonNil(description: reference.description)
    }

    /// Pass a reference to a component.
    /// `lookupOnce()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// The value may itself be a reference. If you want to follow all
    /// references until the ReferenceType is found, use `lookup()`.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)`
    public func lookupOnce<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) throws -> Either<OpenAPI.Reference<ReferenceType>, ReferenceType> {
        guard case let .internal(internalReference) = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }
        return try lookupOnce(internalReference)
    }

    /// Pass a reference to a component.
    /// `lookup()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)` or
    ///     `ReferenceCycleError`
    public func lookup<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) throws -> ReferenceType {
        guard case let .internal(internalReference) = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }
        return try lookup(internalReference)
    }

    internal func _lookup<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>, following visitedReferences: Set<AnyHashable> = .init()) throws -> ReferenceType {
        guard case let .internal(internalReference) = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }
        return try _lookup(internalReference, following: visitedReferences)
    }

    /// Pass a reference to a component.
    /// `lookupOnce()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// The value may itself be a reference. If you want to follow all
    /// references until the ReferenceType is found, use `lookup()`.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)`
    public func lookupOnce<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) throws -> Either<OpenAPI.Reference<ReferenceType>, ReferenceType> {
        let value: Either<OpenAPI.Reference<ReferenceType>, ReferenceType>?
        switch ReferenceType.openAPIComponentsKeyPath {
        case .a(let directPath):
            value = reference.name
                .flatMap(OpenAPI.ComponentKey.init(rawValue:))
                .flatMap { self[keyPath: directPath][$0] }
                .map { .b($0) }

        case .b(let referencePath):
            value = reference.name
                .flatMap(OpenAPI.ComponentKey.init(rawValue:))
                .flatMap { self[keyPath: referencePath][$0] }
        }
        guard let value else {
            throw ReferenceError.missingOnLookup(name: reference.name ?? "unnamed", key: ReferenceType.openAPIComponentsKey)
        }
        return value
    }

    /// Pass a reference to a component.
    /// `lookup()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)` or
    ///     `ReferenceCycleError`
    public func lookup<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) throws -> ReferenceType {
        return try _lookup(reference)
    }

    internal func _lookup<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference, following visitedReferences: Set<AnyHashable> = .init()) throws -> ReferenceType {
        if visitedReferences.contains(reference) {
            throw ReferenceCycleError(ref: reference.rawValue)
        }

        switch ReferenceType.openAPIComponentsKeyPath {
        case .a(let directPath):
            let value: ReferenceType? = reference.name
                .flatMap(OpenAPI.ComponentKey.init(rawValue:))
                .flatMap { self[keyPath: directPath][$0] }

            guard let value else {
                throw ReferenceError.missingOnLookup(name: reference.name ?? "unnamed", key: ReferenceType.openAPIComponentsKey)
            }
            return value

        case .b(let referencePath):
            let possibleValue: Either<OpenAPI.Reference<ReferenceType>, ReferenceType>? = reference.name
                .flatMap(OpenAPI.ComponentKey.init(rawValue:))
                .flatMap { self[keyPath: referencePath][$0] }

            guard let possibleValue else {
                throw ReferenceError.missingOnLookup(name: reference.name ?? "unnamed", key: ReferenceType.openAPIComponentsKey)
            }

            switch possibleValue {
            case .a(let newReference):
                return try _lookup(newReference.jsonReference, following: visitedReferences.union([reference]))
            case .b(let value):
                return value
            }
        }
    }

    /// Pass an `Either` with a reference or a component.
    /// `lookup()` will return the component value if it is found
    /// in the Components Object.
    ///
    /// If you want to look something up without throwing, you might want to use the subscript
    /// operator on the `Components`.
    ///
    /// If you also want to fully dereference the value in question instead
    /// of just looking it up see the various `dereference` functions
    /// on this type for more information.
    ///
    /// - Important: Looking up an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always throw an error.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:,key:)` or
    ///     `ReferenceCycleError`
    public func lookup<ReferenceType: ComponentDictionaryLocatable>(_ maybeReference: Either<OpenAPI.Reference<ReferenceType>, ReferenceType>) throws -> ReferenceType {
        switch maybeReference {
        case .a(let reference):
            return try lookup(reference.jsonReference)
        case .b(let value):
            return value
        }
    }

    /// Create an `OpenAPI.Reference`.
    ///
    /// - Throws: If the given name does not refer to an existing component of the given type.
    public func reference<ReferenceType: ComponentDictionaryLocatable & Equatable>(named name: String, ofType type: ReferenceType.Type) throws -> OpenAPI.Reference<ReferenceType> {

        return try OpenAPI.Reference(jsonReference(named: name, ofType: type))
    }

    /// Create a `JSONReference`.
    ///
    /// - Throws: If the given name does not refer to an existing component of the given type.
    public func jsonReference<ReferenceType: ComponentDictionaryLocatable & Equatable>(named name: String, ofType: ReferenceType.Type) throws -> JSONReference<ReferenceType> {
        let internalReference = JSONReference<ReferenceType>.InternalReference.component(name: name)
        let reference = JSONReference<ReferenceType>.internal(internalReference)

        guard contains(internalReference) else {
            throw ReferenceError.missingOnCreation(name: name, key: ReferenceType.openAPIComponentsKey)
        }
        return reference
    }

    public enum ReferenceError: Swift.Error, Equatable, CustomStringConvertible {
        case cannotLookupRemoteReference
        case missingOnCreation(name: String, key: String)
        case missingOnLookup(name: String, key: String)

        public var description: String {
            switch self {
            case .cannotLookupRemoteReference:
                return "You cannot look up remote JSON references in the Components Object local to this file."
            case .missingOnCreation(name: let name, key: let key):
                return "You cannot create references to components that do not exist in the Components Object this way. You can construct a `JSONReference` directly if you need to circumvent this protection. '\(name)' was not found in \(key)."
            case .missingOnLookup(name: let name, key: let key):
                return "Failed to look up a JSON Reference. '\(name)' was not found in \(key)."
            }
        }
    }

    public struct ReferenceCycleError: Swift.Error, Equatable, CustomStringConvertible {
        public let ref: String

        public var description: String {
            return "Encountered a JSON Schema $ref cycle that prevents fully dereferencing document at '\(ref)'. This type of reference cycle is not inherently problematic for JSON Schemas, but it does mean OpenAPIKit cannot fully resolve references because attempting to do so results in an infinite loop over any reference cycles. You should still be able to parse the document, just avoid requesting a `locallyDereferenced()` copy."
        }

        public var localizedDescription: String {
            description
        }
    }
}

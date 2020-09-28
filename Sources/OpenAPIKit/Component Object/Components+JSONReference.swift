//
//  Components+JSONReference.swift
//  
//
//  Created by Mathew Polzin on 3/30/20.
//

extension OpenAPI.Components {
    /// Check if the `Components` contains the given reference or not.
    ///
    /// Look up a reference in this components dictionary. If you want a
    /// non-throwing alternative, you can pull a `JSONReference.InternalReference`
    /// out of your `JSONReference` and pass that to `contains`
    /// instead.
    ///
    /// - Throws: If the given reference cannot be checked against `Components`
    ///     then this method will throw `ReferenceError`. This will occur when
    ///     the given reference is a remote file reference.
    public func contains<ReferenceType: Equatable & ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) throws -> Bool {
        guard case .internal(let localReference) = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }

        return contains(localReference)
    }

    /// Check if the `Components` contains the given internal reference or not.
    public func contains<ReferenceType: Equatable & ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) -> Bool {
        return reference.name
            .flatMap(OpenAPI.ComponentKey.init(rawValue:))
            .map { self[keyPath: ReferenceType.openAPIComponentsKeyPath].contains(key: $0) }
            ?? false
    }

    /// Retrieve a referenced item from the `Components` or
    /// just return the item directly depending on what value
    /// the `Either` contains.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ maybeReference: Either<JSONReference<ReferenceType>, ReferenceType>) -> ReferenceType? {
        switch maybeReference {
        case .a(let reference):
            return self[reference]
        case .b(let value):
            return value
        }
    }

    /// Retrieve item referenced from the `Components`.
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
    /// If you want a throwing lookup, use the `lookup()` method.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) -> ReferenceType? {
        return reference.name
            .flatMap(OpenAPI.ComponentKey.init(rawValue:))
            .flatMap { self[keyPath: ReferenceType.openAPIComponentsKeyPath][$0] }
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
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether the reference points to another file or just points to a component in
    ///     the same file that cannot be found in the Components Object.
    public func lookup<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) throws -> ReferenceType {
        guard case .internal = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }
        guard let value = self[reference] else {
            throw ReferenceError.missingOnLookup(name: reference.name ?? "unnamed", key: ReferenceType.openAPIComponentsKey)
        }
        return value
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
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether the reference points to another file or just points to a component in
    ///     the same file that cannot be found in the Components Object.
    public func lookup<ReferenceType: ComponentDictionaryLocatable>(_ maybeReference: Either<JSONReference<ReferenceType>, ReferenceType>) throws -> ReferenceType {
        switch maybeReference {
        case .a(let reference):
            return try lookup(reference)
        case .b(let value):
            return value
        }
    }

    /// Create a `JSONReference`.
    ///
    /// - Throws: If the given name does not refer to an existing component of the given type.
    public func reference<ReferenceType: ComponentDictionaryLocatable & Equatable>(named name: String, ofType: ReferenceType.Type) throws -> JSONReference<ReferenceType> {
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
}

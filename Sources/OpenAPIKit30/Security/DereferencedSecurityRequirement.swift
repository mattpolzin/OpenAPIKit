//
//  DereferencedSecurityRequirement.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

import OpenAPIKitCore

/// An `OpenAPI.SecurityRequirement` type that
/// contains the actual security schemas it would otherwise
/// just be referencing with the keys of the Security Requirement
/// dictionary.
public struct DereferencedSecurityRequirement: Equatable {
    /// The `OpenAPI.SecurityRequirement` representation of this
    /// `DereferencedSecurityRequirement`.
    public let underlyingSecurityRequirement: OpenAPI.SecurityRequirement

    /// A dictionary mapping security scheme names to the schemes themselves
    /// and (when relevant) the security scopes required on the given schemes.
    public let schemes: [String: ScopedScheme]

    /// Create a `DereferencedSecurityRequirement` if all references in the
    /// security requirement can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ securityRequirement: OpenAPI.SecurityRequirement,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>
    ) throws {

        let scopedSchemes = try securityRequirement.map { reference, scopes -> (String, ScopedScheme) in
            let scheme = try components.lookup(reference)
            // we know it has a name because it was just found in the
            // Components Object (or else the previous line would have thrown).
            let name = reference.name!
            let scopedScheme = ScopedScheme(name: name, securityScheme: scheme, requiredScopes: scopes)
            return (name, scopedScheme)
        }
        self.schemes = Dictionary(scopedSchemes, uniquingKeysWith: { $1 })

        self.underlyingSecurityRequirement = securityRequirement
    }

    /// A combination of a `SecurityScheme` and the scopes
    /// on that scheme that are required.
    ///
    /// For example, a scheme might define both `read` and `write`
    /// scopes but a `GET` operation may only require the `read` scope.
    public struct ScopedScheme: Equatable {
        /// The name used to identify the security scheme in the
        /// Component Object.
        public let name: String

        public let securityScheme: OpenAPI.SecurityScheme
        /// If the security scheme is of type "oauth2" or "openIdConnect",
        /// then `requiredScopes` is a list of scope names required for
        /// the execution, and the list MAY be empty if authorization does
        /// not require a specified scope. For other security scheme types,
        /// the array MUST be empty.
        ///
        /// See  [Security Requirement Object](https://spec.openapis.org/oas/v3.0.4.html#security-requirement-object) for more.
        public let requiredScopes: [String]
    }
}

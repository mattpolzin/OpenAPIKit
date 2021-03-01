//
//  ResolvedDocument.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

import OpenAPIKitCore

/// A resolved document is a fully dereferenced
/// OpenAPI document that has been further distilled
/// to canonical representations of each component. You
/// create a `ResolvedDocument` by calling the `resolved()`
/// method on a `DereferencedDocument`.
///
/// OpenAPI documents have two distinct forms of
/// distributing information such that not all relevant
/// bits of information are available in one structural
/// part of an OpenAPI Document.
///
/// 1. Documents can contain references. This is great
///     because authors can make one part of an
///     OpenAPI document more concise by referencing
///     a component instead of writing it inline and it also
///     allows shared definitions to be re-used throughout
///     the document.
/// 2. Documents can define and override certain things at
///     different levels of their structure. For example, a
///     document may define a shared set of Security
///     Requirements at the root and then override those
///     Security Requirements for particular Operations.
///
/// Both of these features of OpenAPI documents make it
/// impossible to answer certain questions about a particular
/// route or endpoint without looking to multiple disparate parts
/// of the document and then applying certain rules to determine
/// the relevant semantic definition of the route or endpoint being
/// studied.
///
/// OpenAPIKit defines canonical forms (i.e. the only true definitions)
/// of endpoints, routes, and the whole document. These types (named
/// `ResolvedEndpoint`, `ResolvedRoute`, and `ResolvedDocument`)
/// each allow you to get complete information about the respective components
/// without looking to other parts of the document.
///
/// **Example**
///
/// You want to know what all of the parameters for a particular `PATCH` endpoint are.
/// Without the `ResolvedEndpoint` type, you would need to look at the
/// `OpenAPI.Operation` representing the endpoint, the `OpenAPI.PathItem`
/// representing the route containing the endpoint, and you would need to potentially
/// resolve references to the `OpenAPI.Components`.
///
/// With `ResolvedDocument`, the same task is much simpler:
///
///     let document: OpenAPI.Document = ...
///
///     let resolvedDocument = try document
///         .locallyDereferenced()
///         .resolved()
///
///     let endpoint = resolvedDocument
///         .routesByPath["/example/path"]!.patch!
///
///     // This will be all parameters defined anywhere that
///     // apply to this endpoint:
///     let parameters = endpoint.parameters
///
@dynamicMemberLookup
public struct ResolvedDocument: Equatable {
    /// Access the underlying dereferenced document.
    ///
    /// The original `OpenAPI.Document` is the underlying
    /// document of the dereferenced document available here.
    ///
    ///     let resolvedDocument: OpenAPI.Document = ...
    ///
    ///     let dereferencedDocument = resolvedDocument
    ///         .underlyingDocument
    ///
    ///     let originalDocument = resolvedDocument
    ///         .underlyingDocument
    ///         .underlyingDocument
    public let underlyingDocument: DereferencedDocument

    /// The fully resolved routes of this API keyed by the
    /// paths under which the routes found.
    ///
    /// You can get an array of routes (which know what path they
    /// are at as well) with the `routes` property.
    public let routesByPath: OrderedDictionary<OpenAPI.Path, ResolvedRoute>

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Document, T>) -> T {
        return underlyingDocument.underlyingDocument[keyPath: path]
    }

    /// Create a resolved document from a dereferenced document. Externally,
    /// this is exposed via the `DereferencedDocument` `resolved()` method.
    internal init(dereferencedDocument: DereferencedDocument) {
        self.routesByPath = dereferencedDocument.resolvedRoutesByPath()

        self.underlyingDocument = dereferencedDocument
    }

    /// Get an array containing all routes in the document.
    public var routes: [ResolvedRoute] { routesByPath.values }

    /// Get an array containing all endpoints in the document.
    public var endpoints: [ResolvedEndpoint] { routesByPath.values.flatMap { $0.endpoints } }

    // MARK: - Masking definitions
    // The `paths` and `security` just mask the dynamic member lookup
    // of the `OpenAPI.Document` to provide the values from the
    // `DereferencedDocument` instead.

    /// This property maps the path of each route (`OpenAPI.Path`) to the
    /// documentation for that route (`DereferencedPathItem`).
    public var paths: DereferencedPathItem.Map { underlyingDocument.paths }

    /// A declaration of which security mechanisms can be used across the API.
    ///
    /// The list of values includes alternative security requirement objects that can
    /// be used. Only one of the security requirement objects need to be satisfied
    /// to authorize a request. Individual operations can override this definition.
    ///
    /// An empty security requirement in the array means that security is optional.
    public var security: [DereferencedSecurityRequirement] { underlyingDocument.security }
}

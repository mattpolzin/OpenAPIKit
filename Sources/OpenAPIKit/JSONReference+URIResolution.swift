import OpenAPIKitCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public extension JSONReference {
    /// A URI-reference representing this JSON reference.
    ///
    /// Internal references are represented as fragment-only URLs.
    var uriReference: URL {
        switch self {
        case .internal(let reference):
            return reference.uriReference
        case .external(let url):
            return url
        }
    }

    /// Resolve this reference against the given base URI.
    ///
    /// If `baseURI` is `nil`, relative URI-references remain relative.
    func resolvedURI(relativeTo baseURI: URL?) -> URL {
        rebaseURL(uriReference, relativeTo: baseURI)
    }
}

public extension OpenAPI.Reference {
    /// A URI-reference representing this OpenAPI reference.
    var uriReference: URL {
        jsonReference.uriReference
    }

    /// Resolve this reference against the given base URI.
    ///
    /// If `baseURI` is `nil`, relative URI-references remain relative.
    func resolvedURI(relativeTo baseURI: URL?) -> URL {
        jsonReference.resolvedURI(relativeTo: baseURI)
    }
}

private extension JSONReference.InternalReference {
    var uriReference: URL {
        var components = URLComponents()
        components.fragment = String(rawValue.dropFirst())
        return components.url!
    }
}

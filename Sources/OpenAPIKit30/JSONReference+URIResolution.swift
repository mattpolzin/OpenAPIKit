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
            return URL(string: reference.rawValue)!
        case .external(let url):
            return url
        }
    }

    /// Resolve this reference against the given base URI.
    ///
    /// If `baseURI` is `nil`, relative URI-references remain relative.
    func resolvedURI(relativeTo baseURI: URL?) -> URL {
        uriReference.resolvedURI(relativeTo: baseURI)
    }
}

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public extension URL {
    /// Resolve this URI-reference against the given base URI.
    ///
    /// If `baseURI` is `nil`, relative URI-references remain relative.
    func resolvedURI(relativeTo baseURI: URL?) -> URL {
        if let baseURI,
           let resolvedURI = URL(string: relativeString, relativeTo: baseURI)?.absoluteURL {
            return resolvedURI
        }

        return self
    }
}

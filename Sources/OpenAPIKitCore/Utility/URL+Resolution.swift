#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Resolve a URI-reference as a relative URL against the given base URI.
///
/// If `baseURI` is `nil`, relative URI-references remain relative.
public func rebaseURL(_ target: URL, relativeTo baseURI: URL?) -> URL {
    if let baseURI,
      let resolvedURI = URL(string: target.relativeString, relativeTo: baseURI)?.absoluteURL
    {
        return resolvedURI
    }

    return target
}

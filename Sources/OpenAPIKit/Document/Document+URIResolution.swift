import OpenAPIKitCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public extension OpenAPI.Document {
    /// Establish the base URI for this document.
    ///
    /// If the document has a `$self`, it is resolved against the retrieval URI.
    /// Otherwise, the retrieval URI itself is the established base URI.
    func baseURI(relativeTo retrievalURI: URL? = nil) -> URL? {
        selfURI?.resolvedURI(relativeTo: retrievalURI) ?? retrievalURI
    }

    /// Resolve a JSON reference against this document's established base URI.
    func resolvedURI<ReferenceType>(
        for reference: JSONReference<ReferenceType>,
        relativeTo retrievalURI: URL? = nil
    ) -> URL {
        reference.resolvedURI(relativeTo: baseURI(relativeTo: retrievalURI))
    }

    /// Resolve an OpenAPI reference against this document's established base URI.
    func resolvedURI<ReferenceType>(
        for reference: OpenAPI.Reference<ReferenceType>,
        relativeTo retrievalURI: URL? = nil
    ) -> URL {
        reference.resolvedURI(relativeTo: baseURI(relativeTo: retrievalURI))
    }
}

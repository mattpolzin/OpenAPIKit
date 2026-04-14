#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public extension OpenAPI.Document {
    /// Establish the base URI for this document.
    ///
    /// OpenAPI 3.0 documents do not support `$self`, so the retrieval URI is
    /// the established base URI.
    func baseURI(relativeTo retrievalURI: URL? = nil) -> URL? {
        retrievalURI
    }

    /// Resolve a JSON reference against this document's established base URI.
    func resolvedURI<ReferenceType>(
        for reference: JSONReference<ReferenceType>,
        relativeTo retrievalURI: URL? = nil
    ) -> URL {
        reference.resolvedURI(relativeTo: baseURI(relativeTo: retrievalURI))
    }
}

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKit30
import XCTest

final class JSONSchemaURIResolutionTests: XCTestCase {
    func test_schemaBaseURIFallsBackToParentBaseURIWithoutIdentifier() {
        let schema = JSONSchema.string

        XCTAssertEqual(
            schema.baseURI(relativeTo: URL(string: "https://example.com/root/openapi.yaml")!),
            URL(string: "https://example.com/root/openapi.yaml")!
        )
    }
}

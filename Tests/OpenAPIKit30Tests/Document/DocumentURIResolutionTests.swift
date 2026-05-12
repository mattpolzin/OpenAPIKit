#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKit30
import XCTest

final class DocumentURIResolutionTests: XCTestCase {
    func test_baseURIReturnsRetrievalURI() {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        XCTAssertEqual(
            document.baseURI(relativeTo: URL(string: "https://example.com/root/openapi.yaml")!),
            URL(string: "https://example.com/root/openapi.yaml")!
        )
    }

    func test_documentResolvedURIUsesRetrievalURIAsBaseURI() {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let reference = JSONReference<JSONSchema>.external(URL(string: "shared.yaml#/components/schemas/User")!)

        XCTAssertEqual(
            document.resolvedURI(
                for: reference,
                relativeTo: URL(string: "https://example.com/root/index.yaml")!
            ).absoluteString,
            "https://example.com/root/shared.yaml#/components/schemas/User"
        )
    }
}

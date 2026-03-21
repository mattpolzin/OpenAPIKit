#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKit
import XCTest

final class DocumentURIResolutionTests: XCTestCase {
    func test_baseURIFallsBackToRetrievalURIWhenSelfURIIsAbsent() {
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

    func test_baseURIResolvesSelfURIAgainstRetrievalURI() {
        let document = OpenAPI.Document(
            selfURI: URL(string: "descriptions/openapi.yaml")!,
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        XCTAssertEqual(
            document.baseURI(relativeTo: URL(string: "https://example.com/root/index.yaml")!),
            URL(string: "https://example.com/root/descriptions/openapi.yaml")!
        )
    }

    func test_documentResolvedURIUsesEstablishedBaseURI() {
        let document = OpenAPI.Document(
            selfURI: URL(string: "descriptions/openapi.yaml")!,
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
            "https://example.com/root/descriptions/shared.yaml#/components/schemas/User"
        )
    }

    func test_documentResolvedURIUsesEstablishedBaseURIForOpenAPIReference() {
        let document = OpenAPI.Document(
            selfURI: URL(string: "descriptions/openapi.yaml")!,
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let reference = OpenAPI.Reference<JSONSchema>.component(named: "User")

        XCTAssertEqual(
            document.resolvedURI(
                for: reference,
                relativeTo: URL(string: "https://example.com/root/index.yaml")!
            ).absoluteString,
            "https://example.com/root/descriptions/openapi.yaml#/components/schemas/User"
        )
    }

    func test_documentResolvedURIPreservesRelativeReferenceWithoutEstablishedBaseURI() {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let reference = JSONReference<JSONSchema>.external(URL(string: "shared.yaml#/components/schemas/User")!)

        XCTAssertEqual(
            document.resolvedURI(for: reference, relativeTo: nil).relativeString,
            "shared.yaml#/components/schemas/User"
        )
    }
}

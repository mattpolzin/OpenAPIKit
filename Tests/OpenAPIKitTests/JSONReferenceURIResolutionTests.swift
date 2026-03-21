#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKit
import XCTest

final class JSONReferenceURIResolutionTests: XCTestCase {
    func test_jsonReference_uriReferencePreservesInternalReferenceAsFragment() {
        let reference = JSONReference<JSONSchema>.component(named: "hello")

        XCTAssertEqual(reference.uriReference.relativeString, "#/components/schemas/hello")
    }

    func test_jsonReference_resolvedURIResolvesInternalAndExternalReferencesAgainstBaseURI() {
        let baseURI = URL(string: "https://example.com/schemas/root.yaml")!

        let internalReference = JSONReference<JSONSchema>.component(named: "hello")
        XCTAssertEqual(
            internalReference.resolvedURI(relativeTo: baseURI).absoluteString,
            "https://example.com/schemas/root.yaml#/components/schemas/hello"
        )

        let externalReference = JSONReference<JSONSchema>.external(URL(string: "other.yaml#/components/schemas/world")!)
        XCTAssertEqual(
            externalReference.resolvedURI(relativeTo: baseURI).absoluteString,
            "https://example.com/schemas/other.yaml#/components/schemas/world"
        )
    }

    func test_jsonReference_resolvedURIWithoutBasePreservesRelativeReference() {
        let reference = JSONReference<JSONSchema>.external(URL(string: "other.yaml#/components/schemas/world")!)

        XCTAssertEqual(
            reference.resolvedURI(relativeTo: nil).relativeString,
            "other.yaml#/components/schemas/world"
        )
    }

    func test_openAPIReference_uriReferenceReliesOnUnderlyingJSONReference() {
        let reference = OpenAPI.Reference<JSONSchema>.component(named: "hello")

        XCTAssertEqual(reference.uriReference.relativeString, "#/components/schemas/hello")
    }

    func test_openAPIReference_resolvedURIReliesOnUnderlyingJSONReference() {
        let baseURI = URL(string: "https://example.com/schemas/root.yaml")!
        let reference = OpenAPI.Reference<JSONSchema>.component(named: "hello")

        XCTAssertEqual(
            reference.resolvedURI(relativeTo: baseURI).absoluteString,
            "https://example.com/schemas/root.yaml#/components/schemas/hello"
        )
    }
}

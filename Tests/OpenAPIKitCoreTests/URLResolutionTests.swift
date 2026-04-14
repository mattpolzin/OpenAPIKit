#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKitCore
import XCTest

final class URLResolutionTests: XCTestCase {
    func test_resolvedURIResolvesRelativeReferenceAgainstBaseURI() {
        let reference = URL(string: "schemas/user.yaml#/User")!
        let baseURI = URL(string: "https://example.com/root/openapi.yaml")!

        XCTAssertEqual(
            reference.resolvedURI(relativeTo: baseURI),
            URL(string: "https://example.com/root/schemas/user.yaml#/User")!
        )
    }

    func test_resolvedURIPreservesRelativeReferenceWithoutBaseURI() {
        let reference = URL(string: "schemas/user.yaml#/User")!

        XCTAssertEqual(reference.resolvedURI(relativeTo: nil), reference)
    }

    func test_resolvedURIPreservesAbsoluteReferenceWithoutBaseURI() {
        let reference = URL(string: "https://example.com/schemas/user.yaml#/User")!

        XCTAssertEqual(reference.resolvedURI(relativeTo: nil), reference)
    }
}

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKit
import XCTest

final class JSONSchemaURIResolutionTests: XCTestCase {
    func test_schemaBaseURIResolvesIDAgainstParentBaseURI() {
        let schema = JSONSchema.string(
            .init(id: URL(string: "schemas/user.yaml")),
            .init()
        )

        XCTAssertEqual(schema.id, URL(string: "schemas/user.yaml"))
        XCTAssertEqual(
            schema.baseURI(relativeTo: URL(string: "https://example.com/root/openapi.yaml")!),
            URL(string: "https://example.com/root/schemas/user.yaml")!
        )
    }

    func test_schemaIDRoundTripsThroughEncoding() throws {
        let schema = JSONSchema.string(
            .init(id: URL(string: "schemas/user.yaml")),
            .init()
        )

        let encoded = try orderUnstableTestStringFromEncoding(of: schema)

        assertJSONEquivalent(
            encoded,
            """
            {
              "$id" : "schemas\\/user.yaml",
              "type" : "string"
            }
            """
        )
    }
}

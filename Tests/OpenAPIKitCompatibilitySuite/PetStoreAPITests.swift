//
//  PetStoreAPITests.swift
//
//
//  Created by Mathew Polzin on 2/17/20.
//

import XCTest
import OpenAPIKit
import Yams
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class PetStoreAPICampatibilityTests: XCTestCase {
    var petStoreAPI: Result<OpenAPI.Document, Error>? = nil
    var apiDoc: OpenAPI.Document? {
        guard case .success(let document) = petStoreAPI else { return nil }
        return document
    }

    override func setUp() {
        if petStoreAPI == nil {
            petStoreAPI = Result {
                try YAMLDecoder().decode(
                    OpenAPI.Document.self,
                    from: String(contentsOf: URL(string: "https://raw.githubusercontent.com/swagger-api/swagger-petstore/master/src/main/resources/openapi.yaml")!)
                )
            }
        }
    }

    func test_successfullyParsedDocument() {
        switch petStoreAPI {
        case nil:
            XCTFail("Did not attempt to pull Pet Store API documentation like expected.")
        case .failure(let error):
            let prettyError = OpenAPI.Error(from: error)
            XCTFail(prettyError.localizedDescription + "\n coding path: " + prettyError.codingPathString)
        case .success:
            break
        }
    }

    func test_passesValidation() throws {
        guard let apiDoc = apiDoc else { return }

        try apiDoc.validate()
    }

    func test_successfullyParsedBasicMetadata() throws {
        guard let apiDoc = apiDoc else { return }

        // title is Swagger Petstore - OpenAPI 3.0
        XCTAssertEqual(apiDoc.info.title, "Swagger Petstore - OpenAPI 3.0")

        // description is set
        XCTAssertFalse(apiDoc.info.description?.isEmpty ?? true)

        // contact email is "apiteam@swagger.io"
        XCTAssertEqual(apiDoc.info.contact?.email, "apiteam@swagger.io")

        // no contact name is provided
        XCTAssert(apiDoc.info.contact?.name?.isEmpty ?? true)

        // server is specified
        XCTAssertNotNil(apiDoc.servers.first)
        XCTAssertEqual(apiDoc.servers.first?.url.path, "/v3")
    }

    func test_successfullyParsedTags() throws {
        guard let apiDoc = apiDoc else { return }

        XCTAssertEqual(apiDoc.tags?.map { $0.name }, ["pet", "store", "user"])
    }

    func test_successfullyParsedRoutes() throws {
        guard let apiDoc = apiDoc else { return }

        // just check for a few of the known paths
        XCTAssert(apiDoc.paths.contains(key: "/pet"))
        XCTAssert(apiDoc.paths.contains(key: "/pet/findByStatus"))
        XCTAssert(apiDoc.paths.contains(key: "/pet/findByTags"))
        XCTAssert(apiDoc.paths.contains(key: "/pet/{petId}"))
        XCTAssert(apiDoc.paths.contains(key: "/pet/{petId}/uploadImage"))
        XCTAssert(apiDoc.paths.contains(key: "/store/inventory"))

        // check for a known POST response
        XCTAssertNotNil(apiDoc.paths["/pet/{petId}/uploadImage"]?.post?.responses[200 as OpenAPI.Response.StatusCode])

        // and a known GET response
        XCTAssertNotNil(apiDoc.paths["/pet/{petId}"]?.get?.responses[200 as OpenAPI.Response.StatusCode])

        // check for parameters
        XCTAssertFalse(apiDoc.paths["/pet/{petId}"]?.get?.parameters.isEmpty ?? true)
        XCTAssertEqual(apiDoc.paths["/pet/{petId}"]?.get?.parameters.first?.parameterValue?.name, "petId")
        XCTAssertEqual(apiDoc.paths["/pet/{petId}"]?.get?.parameters.first?.parameterValue?.context, .path)
        XCTAssertEqual(apiDoc.paths["/pet/{petId}"]?.get?.parameters.first?.parameterValue?.schemaOrContent.schemaValue, .integer(format: .int64))
    }

    func test_successfullyParsedComponents() throws {
        guard let apiDoc = apiDoc else { return }

        // check for known schema
        XCTAssertNotNil(apiDoc.components.schemas["Customer"])
        guard case .object(_, let objectContext) = apiDoc.components[JSONReference<JSONSchema>.component(named: "Customer")] else {
            XCTFail("Expected customer schema to be an object")
            return
        }
        XCTAssertEqual(objectContext.properties["username"], .string(required: false, example: "fehguy"))

        // check for known security scheme
        XCTAssertNotNil(apiDoc.components.securitySchemes["api_key"])
        XCTAssertEqual(apiDoc.components.securitySchemes["api_key"], OpenAPI.SecurityScheme.apiKey(name: "api_key", location: .header))
    }

    func test_dereferencedComponents() throws {
        guard let apiDoc = apiDoc else { return }

        let dereferencedDoc = try apiDoc.locallyDereferenced()

        // Pet schema is a $ref to Components Object
        XCTAssertEqual(dereferencedDoc.paths["/pet"]?.post?.responses[status: 200]?.content[.json]?.schema.objectContext?.properties["name"]?.jsonSchema, try JSONSchema.string.with(example: "doggie"))
    }

    func test_resolveDocument() throws {
        guard let apiDoc = apiDoc else { return }

        let resolvedDoc = try apiDoc.locallyDereferenced().resolved()

        XCTAssertEqual(resolvedDoc.routes.count, 13)
        XCTAssertEqual(resolvedDoc.endpoints.count, 19)
        XCTAssertEqual(resolvedDoc.tags?.count, resolvedDoc.allTags.count)
    }
}

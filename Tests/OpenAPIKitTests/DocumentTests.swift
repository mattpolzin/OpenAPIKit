//
//  DocumentTests.swift
//  
//
//  Created by Mathew Polzin on 10/27/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class DocumentTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.Document(
            info: .init(title: "hi", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let _ = OpenAPI.Document(
            openAPIVersion: .v3_0_2,
            info: .init(title: "hi", version: "1.0"),
            servers: [
                .init(url: URL(string: "https://google.com")!)
            ],
            paths: [
                "/hi/there": .init(
                    parameters: [],
                    get: .init(
                        tags: "hi",
                        parameters: [],
                        responses: [:]
                    )
                )
            ],
            components: .init(schemas: ["hello": .string]),
            security: [],
            tags: ["hi"],
            externalDocs: .init(url: URL(string: "https://google.com")!)
        )
    }

    func test_existingSecuritySchemeSuccess() {
        let docData =
"""
{
    "openapi": "3.0.0",
    "info": {
        "title": "test",
        "version": "1.0"
    },
    "paths": {},
    "components": {
        "securitySchemes": {
            "found": {
                "type": "http",
                "scheme": "basic"
            }
        }
    },
    "security": [
        {
            "found": []
        }
    ]
}
""".data(using: .utf8)!

        XCTAssertNoThrow(try JSONDecoder().decode(OpenAPI.Document.self, from: docData))
    }

    func test_missingSecuritySchemeError() {
        let docData =
"""
{
    "openapi": "3.0.0",
    "info": {
        "title": "test",
        "version": "1.0"
    },
    "paths": {},
    "components": {},
    "security": [
        {
            "missing": []
        }
    ]
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(OpenAPI.Document.self, from: docData)) { err in
            XCTAssertTrue(err is DecodingError)
            guard let decodingError = err as? DecodingError,
                case .dataCorrupted(let context) = decodingError else {
                    XCTFail("Expected data corrupted decoding error")
                    return
            }
            assertJSONEquivalent(context.debugDescription, "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary.")
        }
    }
}

// MARK: - Codable
extension DocumentTests {
    func test_minimal_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  }
}
"""
        )
    }

    func test_minimal_decode() throws {
        let documentData =
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  }
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents
            )
        )
    }

    func test_specifyOpenAPIVersion_encode() throws {
        let document = OpenAPI.Document(
            openAPIVersion: .v3_0_2,
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.2",
  "paths" : {

  }
}
"""
        )
    }

    func test_specifyOpenAPIVersion_decode() throws {
        let documentData =
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.2",
  "paths" : {

  }
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                openAPIVersion: .v3_0_2,
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents
            )
        )
    }

    func test_specifyServers_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [.init(url: URL(string: "http://google.com")!)],
            paths: [:],
            components: .noComponents
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  },
  "servers" : [
    {
      "url" : "http:\\/\\/google.com"
    }
  ]
}
"""
        )
    }

    func test_specifyServers_decode() throws {
        let documentData =
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  },
  "servers" : [
    {
      "url" : "http:\\/\\/google.com"
    }
  ]
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [.init(url: URL(string: "http://google.com")!)],
                paths: [:],
                components: .noComponents
            )
        )
    }

    func test_specifyPaths_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: ["test": .init(summary: "hi")],
            components: .noComponents
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {
    "\\/test" : {
      "summary" : "hi"
    }
  }
}
"""
        )
    }

    func test_specifyPaths_decode() throws {
        let documentData =
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {
    "\\/test" : {
      "summary" : "hi"
    }
  }
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: ["test": .init(summary: "hi")],
                components: .noComponents
            )
        )
    }

    func test_specifySecurity_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .init(schemas: [:],
                              responses: [:],
                              parameters: [:],
                              examples: [:],
                              requestBodies: [:],
                              headers: [:],
                              securitySchemes: ["security": .init(type: .apiKey(name: "key", location: .header))]),
            security: [[.internal(\.securitySchemes, named: "security"):[]]]
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "components" : {
    "securitySchemes" : {
      "security" : {
        "in" : "header",
        "name" : "key",
        "type" : "apiKey"
      }
    }
  },
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  },
  "security" : [
    {
      "security" : [

      ]
    }
  ]
}
"""
        )
    }

    func test_specifySecurity_decode() throws {
        let documentData =
"""
{
  "components" : {
    "securitySchemes" : {
      "security" : {
        "in" : "header",
        "name" : "key",
        "type" : "apiKey"
      }
    }
  },
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  },
  "security" : [
    {
      "security" : [

      ]
    }
  ]
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .init(schemas: [:],
                                  responses: [:],
                                  parameters: [:],
                                  examples: [:],
                                  requestBodies: [:],
                                  headers: [:],
                                  securitySchemes: ["security": .init(type: .apiKey(name: "key", location: .header))]),
                security: [[.internal(\.securitySchemes, named: "security"):[]]]
            )
        )
    }

    func test_specifyTags_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: [.init(name: "hi")]
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  },
  "tags" : [
    {
      "name" : "hi"
    }
  ]
}
"""
        )
    }

    func test_specifyTags_decode() throws {
        let documentData =
"""
{
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  },
  "tags" : [
    {
      "name" : "hi"
    }
  ]
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents,
                tags: [.init(name: "hi")]
            )
        )
    }

    func test_specifyExternalDocs_encode() throws {
        let document = OpenAPI.Document(
            info: .init(title: "API", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            externalDocs: .init(url: URL(string: "http://google.com")!)
        )
        let encodedDocument = try testStringFromEncoding(of: document)

        assertJSONEquivalent(
            encodedDocument,
"""
{
  "externalDocs" : {
    "url" : "http:\\/\\/google.com"
  },
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  }
}
"""
        )
    }

    func test_specifyExternalDocs_decode() throws {
        let documentData =
"""
{
  "externalDocs" : {
    "url" : "http:\\/\\/google.com"
  },
  "info" : {
    "title" : "API",
    "version" : "1.0"
  },
  "openapi" : "3.0.0",
  "paths" : {

  }
}
""".data(using: .utf8)!
        let document = try testDecoder.decode(OpenAPI.Document.self, from: documentData)

        XCTAssertEqual(
            document,
            OpenAPI.Document(
                info: .init(title: "API", version: "1.0"),
                servers: [],
                paths: [:],
                components: .noComponents,
                externalDocs: .init(url: URL(string: "http://google.com")!)
            )
        )
    }
}

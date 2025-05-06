//
//  DocumentErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit
@preconcurrency import Yams

final class DocumentErrorTests: XCTestCase {

    func test_missingOpenAPIVersion() {
        let documentYML =
        """
        info:
            title: test
            version: 1.0
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `openapi` key in the root Document object but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_wrongTypesOpenAPIVersion() {
        let documentYML =
        """
        openapi: null
        info:
            title: test
            version: 1.0
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Inconsistency encountered when parsing `openapi` in the root Document object: Cannot initialize Version from invalid String value null.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "openapi"
            ])
        }

        let documentYML2 =
        """
        openapi: []
        info:
            title: test
            version: 1.0
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML2)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `openapi` value in the root Document object to be parsable as Scalar but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "openapi"
            ])
        }

        let documentYML3 =
        """
        openapi: {}
        info:
            title: test
            version: 1.0
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML3)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `openapi` value in the root Document object to be parsable as Scalar but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "openapi"
            ])
        }
    }

    func test_missingInfo() {
        let documentYML =
        """
        openapi: "3.1.0"
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `info` key in the root Document object but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_wrongTypesInfo() {
        let documentYML =
        """
        openapi: "3.1.0"
        info: null
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `info` value in the root Document object to be parsable as Mapping but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "info"
            ])
        }

        let documentYML2 =
        """
        openapi: "3.1.0"
        info: []
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML2)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `info` value in the root Document object to be parsable as Mapping but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "info"
            ])
        }
    }

    func test_missingTitleInsideInfo() {
        let documentYML =
        """
        openapi: "3.1.0"
        info: {}
        paths: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `title` key in Document.info but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "info"
            ])
        }
    }

    func test_missingNameInsideSecondTag() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths: {}
        tags:
            - name: hi
            - description: missing
            - name: hello
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `name` key in Document.tags[1] but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map {$0.stringValue }, [
                "tags",
                "Index 1"
            ])
        }
    }
}

//
//  RequestContentMapErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/24/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class RequestContentMapErrorTests: XCTestCase {
    /**

            The "wrong type content map key" does not fail right now because OrderedDictionary does not
            throw for keys it cannot decode. This is a shortcoming of OrderedDictionary that should be solved
            in a future release.

     */

//    func test_wrongTypeContentMapKey() {
//        let documentYML =
//"""
//openapi: "3.0.0"
//info:
//    title: test
//    version: 1.0
//paths:
//    /hello/world:
//        get:
//            requestBody:
//                content:
//                    blablabla:
//                        schema:
//                            $ref: #/components/schemas/one
//            responses: {}
//"""
//
//        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in
//
//            let openAPIError = OpenAPI.Error(from: error)
//
//            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find either a $ref or a Request in .requestBody for the **GET** endpoint under `/hello/world` but found neither. \n\nJSONReference<Components, Request> could not be decoded because:\nExpected `requestBody` value in .paths./hello/world.get to be parsable as Mapping but it was not.\n\nRequest could not be decoded because:\nExpected `requestBody` value in .paths./hello/world.get to be parsable as Mapping but it was not..")
//            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
//                "paths",
//                "/hello/world",
//                "get",
//                "requestBody"
//            ])
//        }
//    }

    func test_missingSchemaContent() {
        let documentYML =
"""
openapi: "3.0.0"
info:
    title: test
    version: 1.0
paths:
    /hello/world:
        get:
            requestBody:
                content:
                    application/json: {}
            responses: {}
"""

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `schema` key in .content['application/json'] for the request body of the **GET** endpoint under `/hello/world` but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody",
                "content",
                "application/json"
            ])
            XCTAssertEqual(openAPIError.codingPathString, ".paths['/hello/world'].get.requestBody.content['application/json']")
        }
    }

    func test_wrongTypeContentValue() {
        let documentYML =
"""
openapi: "3.0.0"
info:
    title: test
    version: 1.0
paths:
    /hello/world:
        get:
            requestBody:
                content:
                    application/json: hello
            responses: {}
"""

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `application/json` value in .content for the request body of the **GET** endpoint under `/hello/world` to be parsable as Mapping but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody",
                "content",
                "application/json"
            ])
        }
    }

    func test_incorrectVendorExtension() {
        let documentYML =
"""
openapi: "3.0.0"
info:
    title: test
    version: 1.0
paths:
    /hello/world:
        get:
            requestBody:
                content:
                    application/json:
                        schema:
                            type: string
                        x-hello: world
                        invalid: extension
            responses: {}
"""

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Inconsistency encountered when parsing `Vendor Extension` in .content['application/json'] for the request body of the **GET** endpoint under `/hello/world`: Found a vendor extension property that does not begin with the required 'x-' prefix.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody",
                "content",
                "application/json"
            ])
        }
    }
}

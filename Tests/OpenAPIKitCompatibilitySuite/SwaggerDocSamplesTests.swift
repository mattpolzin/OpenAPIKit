//
//  SwaggerDocSamplesTests.swift
//  
//
//  Created by Mathew Polzin on 7/25/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class SwaggerDocSamplesTests: XCTestCase {
    func test_allOfExample() throws {
        let docString = commonBaseDocument + """
paths:
    /pets:
        patch:
            requestBody:
                content:
                    application/json:
                        schema:
                            oneOf:
                                - $ref: '#/components/schemas/Cat'
                                - $ref: '#/components/schemas/Dog'
                            discriminator:
                                propertyName: pet_type
            responses:
                '200':
                    description: Updated
components:
    schemas:
        Pet:
            type: object
            required:
                - pet_type
            properties: #3
                pet_type:
                    type: string
            discriminator:
                propertyName: pet_type
        Dog:
            allOf:
                - $ref: '#/components/schemas/Pet'
                - type: object
                  properties:
                        bark:
                            type: boolean
                        breed:
                            type: string
                            enum: [Dingo, Husky, Retriever, Shepherd]
        Cat:
            allOf:
                - $ref: '#/components/schemas/Pet'
                - type: object
                  properties:
                        hunts:
                            type: boolean
                        age:
                            type: integer
"""

        // test decoding
        do {
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: docString)

            // test validating
            try doc.validate()

            XCTAssertEqual(
                doc.paths["/pets"]?.patch?.requestBody?.requestValue?
                    .content[.json]?.schema.schemaValue,
                JSONSchema.one(
                    of: .reference(.component(named: "Cat")),
                        .reference(.component(named: "Dog")),
                    discriminator: .init(propertyName: "pet_type")
                )
            )

            // test dereferencing and resolving
            let resolvedDoc = try doc.locallyDereferenced().resolved()

            XCTAssertEqual(resolvedDoc.routes.count, 1)
            XCTAssertEqual(resolvedDoc.endpoints.count, 1)

            let dogSchema = doc.components.schemas["Dog"]!
            let catSchema = doc.components.schemas["Cat"]!

            XCTAssertEqual(
                resolvedDoc.endpoints[0].requestBody?
                    .content[.json]?.schema.underlyingJSONSchema,
                JSONSchema.one(
                    of: [
                        catSchema,
                        dogSchema
                    ],
                    discriminator: .init(propertyName: "pet_type")
                )
            )
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }

    func test_oneOfExample() throws {
        let docString = commonBaseDocument + """
paths:
  /pets:
    patch:
      requestBody:
        content:
          application/json:
            schema:
              oneOf:
                - $ref: '#/components/schemas/Cat'
                - $ref: '#/components/schemas/Dog'
      responses:
        '200':
          description: Updated
components:
  schemas:
    Dog:
      type: object
      properties:
        bark:
          type: boolean
        breed:
          type: string
          enum: [Dingo, Husky, Retriever, Shepherd]
    Cat:
      type: object
      properties:
        hunts:
          type: boolean
        age:
          type: integer
"""

        // test decoding
        do {
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: docString)

            // test validating
            try doc.validate()

            // test dereferencing and resolving
            _ = try doc.locallyDereferenced().resolved()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }

    func test_anyOfExample() throws {
        let docString = commonBaseDocument + """
paths:
  /pets:
    patch:
      requestBody:
        content:
          application/json:
            schema:
              anyOf:
                - $ref: '#/components/schemas/PetByAge'
                - $ref: '#/components/schemas/PetByType'
      responses:
        '200':
          description: Updated
components:
  schemas:
    PetByAge:
      type: object
      properties:
        age:
          type: integer
        nickname:
          type: string
      required:
        - age

    PetByType:
      type: object
      properties:
        pet_type:
          type: string
          enum: [Cat, Dog]
        hunts:
          type: boolean
      required:
        - pet_type
"""

        // test decoding
        do {
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: docString)

            // test validating
            try doc.validate()

            // test dereferencing and resolving
            _ = try doc.locallyDereferenced().resolved()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }

    func test_notExample() throws {
        let docString = commonBaseDocument + """
paths:
  /pets:
    patch:
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PetByType'
      responses:
        '200':
          description: Updated
components:
  schemas:
    PetByType:
      type: object
      properties:
        pet_type:
          not:
            type: integer
      required:
        - pet_type
"""

        // test decoding
        do {
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: docString)

            // test validating
            try doc.validate()

            // test dereferencing and resolving
            _ = try doc.locallyDereferenced().resolved()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }

    func test_enumsExample() throws {
        let docString = commonBaseDocument + """
paths:
  /items:
    get:
      parameters:
        - in: query
          name: sort
          description: Sort order
          schema:
            type: string
            enum: [asc, desc]
      responses:
        '200':
          description: OK
"""

        // test decoding
        do {
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: docString)

            // test validating
            try doc.validate()

            // test dereferencing and resolving
            _ = try doc.locallyDereferenced().resolved()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }

    func test_reusableEnumsExample() throws {
        let docString = commonBaseDocument + """
paths:
  /products:
    get:
      parameters:
      - in: query
        name: color
        required: true
        schema:
          $ref: '#/components/schemas/Color'
      responses:
        '200':
          description: OK
components:
  schemas:
    Color:
      type: string
      enum:
        - black
        - white
        - red
        - green
        - blue
"""

        // test decoding
        do {
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: docString)

            // test validating
            try doc.validate()

            // test dereferencing and resolving
            _ = try doc.locallyDereferenced().resolved()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
}

fileprivate let commonBaseDocument = """
openapi: 3.0.0
info:
    title: Sample API
    description: Optional multiline or single-line description in [CommonMark](http://commonmark.org/help/) or HTML.
    version: 0.1.9
servers:
    - url: http://api.example.com/v1
      description: Optional server description, e.g. Main (production) server
    - url: http://staging-api.example.com
      description: Optional server description, e.g. Internal staging server for testing

"""

//
//  LinkTests.swift
//
//
//  Created by Mathieu Barnachon on 7/28/20.
//

import OpenAPIKit
import XCTest
import Yams

final class OpenAPITests: XCTestCase {
    func test_api_with_examples_json() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/api-with-examples.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_callback_example_json() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/callback-example.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_link_example_json() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/link-example.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_petstore_expanded_json() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore-expanded.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_petstore_json() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_uspto_json() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/uspto.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_github_json() throws {
        let url = "https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.json"
        do {
            let url = URL(string: url)!
            let specifications = try Data(contentsOf: url)
            let doc = try JSONDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }

    func test_api_with_examples_yaml() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/api-with-examples.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_callback_example_yaml() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/callback-example.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_link_example_yaml() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/link-example.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_petstore_expanded_yaml() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore-expanded.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_petstore_yaml() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_uspto_yaml() throws {
        let url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/uspto.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
    func test_github_yaml() throws {
        let url = "https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.yaml"
        do {
            let url = URL(string: url)!
            let specifications = try String(contentsOf: url)
            let doc = try YAMLDecoder().decode(OpenAPI.Document.self, from: specifications)

            // test validating
            try doc.validate()
        } catch let error {
            let friendlyError = OpenAPI.Error(from: error)
            throw friendlyError
        }
    }
}

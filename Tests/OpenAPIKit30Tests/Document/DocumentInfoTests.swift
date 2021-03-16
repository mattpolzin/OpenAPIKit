//
//  DocumentInfoTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 10/18/19.
//

import XCTest
import OpenAPIKit30

final class DocumentInfoTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.Document.Info(title: "title", version: "1.0")

        let _ = OpenAPI.Document.Info(
            title: "title",
            description: "description",
            termsOfService: URL(string: "http://google.com")!,
            contact: .init(name: "contact"),
            license: .MIT,
            version: "1.0"
        )
    }

    func test_initLicense() {
        let _ = OpenAPI.Document.Info.License(name: "license")
        let _ = OpenAPI.Document.Info.License(name: "license", url: URL(string: "http://google.com")!)

        let _ = OpenAPI.Document.Info.License.MIT
        let _ = OpenAPI.Document.Info.License.MIT(url: URL(string: "http://google.com")!)
        let _ = OpenAPI.Document.Info.License.apache2
        let _ = OpenAPI.Document.Info.License.apache2(url: URL(string: "http://google.com")!)
    }
}

// MARK: - Codable
extension DocumentInfoTests {
    func test_license_encode() throws {
        let license = OpenAPI.Document.Info.License.MIT

        let encodedLicense = try orderUnstableTestStringFromEncoding(of: license)

        assertJSONEquivalent(
            encodedLicense,
            """
            {
              "name" : "MIT",
              "url" : "https:\\/\\/www.mit.edu\\/~amini\\/LICENSE.md"
            }
            """
        )
    }

    func test_license_decode() throws {
        let licenseData =
        """
        {
          "name" : "MIT",
          "url" : "https:\\/\\/www.mit.edu\\/~amini\\/LICENSE.md"
        }
        """.data(using: .utf8)!
        let license = try orderUnstableDecode(OpenAPI.Document.Info.License.self, from: licenseData)

        XCTAssertEqual(
            license,
            .MIT
        )
    }

    func test_license_withUrl_encode() throws {
        let license = OpenAPI.Document.Info.License.MIT(url: URL(string: "http://google.com")!)

        let encodedLicense = try orderUnstableTestStringFromEncoding(of: license)

        assertJSONEquivalent(
            encodedLicense,
            """
            {
              "name" : "MIT",
              "url" : "http:\\/\\/google.com"
            }
            """
        )
    }

    func test_license_withUrl_decode() throws {
        let licenseData =
        """
        {
          "name" : "MIT",
          "url" : "http://google.com"
        }
        """.data(using: .utf8)!
        let license = try orderUnstableDecode(OpenAPI.Document.Info.License.self, from: licenseData)

        XCTAssertEqual(
            license,
            .MIT(url: URL(string: "http://google.com")!)
        )
    }

    func test_license_withVendorExtension_encode() throws {
        let license = OpenAPI.Document.Info.License(
            name: "MIT",
            url: URL(string: "http://website.com")!,
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )

        let encodedLicense = try orderUnstableTestStringFromEncoding(of: license)

        assertJSONEquivalent(
            encodedLicense,
            """
            {
              "name" : "MIT",
              "url" : "http:\\/\\/website.com",
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_license_withVendorExtension_decode() throws {
        let licenseData =
        """
        {
          "name" : "MIT",
          "url" : "http://website.com",
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!
        let license = try orderUnstableDecode(OpenAPI.Document.Info.License.self, from: licenseData)

        XCTAssertEqual(
            license,
            OpenAPI.Document.Info.License(
                name: "MIT",
                url: URL(string: "http://website.com")!,
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
            )
        )
    }

    func test_contact_name_encode() throws {
        let contact = OpenAPI.Document.Info.Contact(name: "contact")

        let encodedContact = try orderUnstableTestStringFromEncoding(of: contact)

        assertJSONEquivalent(
            encodedContact,
            """
            {
              "name" : "contact"
            }
            """
        )
    }

    func test_contact_name_decode() throws {
        let contactData =
        """
        {
          "name" : "contact"
        }
        """.data(using: .utf8)!
        let contact = try orderUnstableDecode(OpenAPI.Document.Info.Contact.self, from: contactData)

        XCTAssertEqual(
            contact,
            .init(name: "contact")
        )
    }

    func test_contact_url_encode() throws {
        let contact = OpenAPI.Document.Info.Contact(url: URL(string: "http://google.com")!)

        let encodedContact = try orderUnstableTestStringFromEncoding(of: contact)

        assertJSONEquivalent(
            encodedContact,
            """
            {
              "url" : "http:\\/\\/google.com"
            }
            """
        )
    }

    func test_contact_url_decode() throws {
        let contactData =
        """
        {
          "url" : "http://google.com"
        }
        """.data(using: .utf8)!
        let contact = try orderUnstableDecode(OpenAPI.Document.Info.Contact.self, from: contactData)

        XCTAssertEqual(
            contact,
            .init(url: URL(string: "http://google.com")!)
        )
    }

    func test_contact_email_encode() throws {
        let contact = OpenAPI.Document.Info.Contact(email: "email")

        let encodedContact = try orderUnstableTestStringFromEncoding(of: contact)

        assertJSONEquivalent(
            encodedContact,
            """
            {
              "email" : "email"
            }
            """
        )
    }

    func test_contact_email_decode() throws {
        let contactData =
        """
        {
          "email" : "email"
        }
        """.data(using: .utf8)!
        let contact = try orderUnstableDecode(OpenAPI.Document.Info.Contact.self, from: contactData)

        XCTAssertEqual(
            contact,
            .init(email: "email")
        )
    }

    func test_contact_vendorExtensions_encode() throws {
        let contact = OpenAPI.Document.Info.Contact(
            email: "email",
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )

        let encodedContact = try orderUnstableTestStringFromEncoding(of: contact)

        assertJSONEquivalent(
            encodedContact,
             """
            {
              "email" : "email",
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_contact_vendorExtensions_decode() throws {
        let contactData =
        """
        {
          "email" : "email",
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!
        let contact = try orderUnstableDecode(OpenAPI.Document.Info.Contact.self, from: contactData)

        XCTAssertEqual(
            contact,
            .init(
                email: "email",
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
            )
        )
    }

    func test_info_minimal_encode() throws {
        let info = OpenAPI.Document.Info(title: "title", version: "1.0")

        let encodedInfo = try orderUnstableTestStringFromEncoding(of: info)

        assertJSONEquivalent(
            encodedInfo,
            """
            {
              "title" : "title",
              "version" : "1.0"
            }
            """
        )
    }

    func test_info_minimal_decode() throws {
        let infoData =
        """
        {
          "title" : "title",
          "version" : "1.0"
        }
        """.data(using: .utf8)!
        let info = try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)

        XCTAssertEqual(
            info,
            .init(title: "title", version: "1.0")
        )
    }

    func test_info_withDescription_encode() throws {
        let info = OpenAPI.Document.Info(
            title: "title",
            description: "description",
            version: "1.0"
        )

        let encodedInfo = try orderUnstableTestStringFromEncoding(of: info)

        assertJSONEquivalent(
            encodedInfo,
            """
            {
              "description" : "description",
              "title" : "title",
              "version" : "1.0"
            }
            """
        )
    }

    func test_info_withDescription_decode() throws {
        let infoData =
        """
        {
          "description" : "description",
          "title" : "title",
          "version" : "1.0"
        }
        """.data(using: .utf8)!
        let info = try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)

        XCTAssertEqual(
            info,
            .init(
                title: "title",
                description: "description",
                version: "1.0"
            )
        )
    }
  
    func test_info_withTOS_encode() throws {
        let info = OpenAPI.Document.Info(
            title: "title",
            termsOfService: URL(string: "http://google.com")!,
            version: "1.0"
        )

        let encodedInfo = try orderUnstableTestStringFromEncoding(of: info)

        assertJSONEquivalent(
            encodedInfo,
            """
            {
              "termsOfService" : "http:\\/\\/google.com",
              "title" : "title",
              "version" : "1.0"
            }
            """
        )
    }

    func test_info_withTOS_decode() throws {
        let infoData =
        """
        {
          "termsOfService" : "http://google.com",
          "title" : "title",
          "version" : "1.0"
        }
        """.data(using: .utf8)!
        let info = try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)

        XCTAssertEqual(
            info,
            .init(
                title: "title",
                termsOfService: URL(string: "http://google.com")!,
                version: "1.0"
            )
        )
    }

    func test_info_withTOS_decode_fails() {
        let infoData =
        """
        {
          "termsOfService" : "#$%^&*",
          "title" : "title",
          "version" : "1.0"
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError( try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)) { error in
            XCTAssertEqual(OpenAPI.Error(from: error).localizedDescription, "Inconsistency encountered when parsing `termsOfService`: If specified, must be a valid URL.")
        }
    }

    func test_info_withContact_encode() throws {
        let info = OpenAPI.Document.Info(
            title: "title",
            contact: .init(name: "hello"),
            version: "1.0"
        )

        let encodedInfo = try orderUnstableTestStringFromEncoding(of: info)

        assertJSONEquivalent(
            encodedInfo,
            """
            {
              "contact" : {
                "name" : "hello"
              },
              "title" : "title",
              "version" : "1.0"
            }
            """
        )
    }

    func test_info_withContact_decode() throws {
        let infoData =
        """
        {
          "contact" : {
            "name" : "hello"
          },
          "title" : "title",
          "version" : "1.0"
        }
        """.data(using: .utf8)!
        let info = try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)

        XCTAssertEqual(
            info,
            .init(
                title: "title",
                contact: .init(name: "hello"),
                version: "1.0"
            )
        )
    }

    func test_info_withLicense_encode() throws {
        let info = OpenAPI.Document.Info(
            title: "title",
            license: .init(name: "license"),
            version: "1.0"
        )

        let encodedInfo = try orderUnstableTestStringFromEncoding(of: info)

        assertJSONEquivalent(
            encodedInfo,
            """
            {
              "license" : {
                "name" : "license"
              },
              "title" : "title",
              "version" : "1.0"
            }
            """
        )
    }

    func test_info_withLicense_decode() throws {
        let infoData =
        """
        {
          "license" : {
            "name" : "license"
          },
          "title" : "title",
          "version" : "1.0"
        }
        """.data(using: .utf8)!
        let info = try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)

        XCTAssertEqual(
            info,
            .init(
                title: "title",
                license: .init(name: "license"),
                version: "1.0"
            )
        )
    }

    func test_info_withVendorExtension_encode() throws {
        let info = OpenAPI.Document.Info(
            title: "title",
            license: .init(name: "license"),
            version: "1.0",
            vendorExtensions: ["x-speacialFeature": ["hello", "world"]]
        )

        let encodedInfo = try orderUnstableTestStringFromEncoding(of: info)

        assertJSONEquivalent(
            encodedInfo,
            """
            {
              "license" : {
                "name" : "license"
              },
              "title" : "title",
              "version" : "1.0",
              "x-speacialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_info_withVendorExtension_decode() throws {
        let infoData =
        """
        {
          "license" : {
            "name" : "license"
          },
          "title" : "title",
          "version" : "1.0",
          "x-speacialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!
        let info = try orderUnstableDecode(OpenAPI.Document.Info.self, from: infoData)

        XCTAssertEqual(
            info,
            .init(
                title: "title",
                license: .init(name: "license"),
                version: "1.0",
                vendorExtensions: ["x-speacialFeature": ["hello", "world"]]
            )
        )
    }
}

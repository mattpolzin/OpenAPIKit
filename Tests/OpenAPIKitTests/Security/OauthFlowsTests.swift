//
//  OAuthFlowsTests.swift
//  
//
//  Created by Mathew Polzin on 1/23/20.
//

import OpenAPIKit
import XCTest

final class OAuthFlowsTests: XCTestCase {
    let testUrl = URL(string: "http://google.com")!

    func test_initialize() {

        let scopes: OrderedDictionary<String, String> = [
            "read:test": "read things",
            "write:test": "write things"
        ]

        let implicitFlow = OpenAPI.OAuthFlows.Implicit(
            authorizationUrl: testUrl,
            refreshUrl: testUrl,
            scopes: scopes
        )

        XCTAssertEqual(implicitFlow.authorizationUrl, testUrl)
        XCTAssertEqual(implicitFlow.refreshUrl, testUrl)
        XCTAssertEqual(implicitFlow.scopes, scopes)

        let passwordFlow = OpenAPI.OAuthFlows.Password(
            tokenUrl: testUrl,
            refreshUrl: testUrl,
            scopes: scopes
        )

        XCTAssertEqual(passwordFlow.tokenUrl, testUrl)
        XCTAssertEqual(passwordFlow.refreshUrl, testUrl)
        XCTAssertEqual(passwordFlow.scopes, scopes)

        let clientCredentialsFlow = OpenAPI.OAuthFlows.ClientCredentials(
            tokenUrl: testUrl,
            refreshUrl: testUrl,
            scopes: scopes
        )

        XCTAssertEqual(clientCredentialsFlow.tokenUrl, testUrl)
        XCTAssertEqual(clientCredentialsFlow.refreshUrl, testUrl)
        XCTAssertEqual(clientCredentialsFlow.scopes, scopes)

        let authorizationCodeFlow = OpenAPI.OAuthFlows.AuthorizationCode(
            authorizationUrl: testUrl,
            tokenUrl: testUrl,
            refreshUrl: testUrl,
            scopes: scopes
        )

        XCTAssertEqual(authorizationCodeFlow.authorizationUrl, testUrl)
        XCTAssertEqual(authorizationCodeFlow.tokenUrl, testUrl)
        XCTAssertEqual(authorizationCodeFlow.refreshUrl, testUrl)
        XCTAssertEqual(authorizationCodeFlow.scopes, scopes)

        let flows = OpenAPI.OAuthFlows(
            implicit: implicitFlow,
            password: passwordFlow,
            clientCredentials: clientCredentialsFlow,
            authorizationCode: authorizationCodeFlow
        )

        XCTAssertEqual(flows.implicit, implicitFlow)
        XCTAssertEqual(flows.password, passwordFlow)
        XCTAssertEqual(flows.clientCredentials, clientCredentialsFlow)
        XCTAssertEqual(flows.authorizationCode, authorizationCodeFlow)
    }
}

// MARK: - Codable Tests
extension OAuthFlowsTests {
    func test_minimal_encode() throws {
        let oauthFlows = OpenAPI.OAuthFlows()

        let encodedFlows = try orderUnstableTestStringFromEncoding(of: oauthFlows)

        assertJSONEquivalent(
            encodedFlows,
            """
            {

            }
            """
            )
    }

    func test_minimal_decode() throws {
        let oauthFlowsData =
        """
        {}
        """.data(using: .utf8)!

        let oauthFlows = try orderUnstableDecode(OpenAPI.OAuthFlows.self, from: oauthFlowsData)

        XCTAssertEqual(oauthFlows, OpenAPI.OAuthFlows())
    }

    func test_maximal_encode() throws {
        let scopes: OrderedDictionary<String, String> = [
            "read:test": "read things",
            "write:test": "write things"
        ]

        let oauthFlows = OpenAPI.OAuthFlows(
            implicit: OpenAPI.OAuthFlows.Implicit(
                authorizationUrl: testUrl,
                refreshUrl: testUrl,
                scopes: scopes
            ),
            password: OpenAPI.OAuthFlows.Password(
                tokenUrl: testUrl,
                refreshUrl: testUrl,
                scopes: scopes
            ),
            clientCredentials: OpenAPI.OAuthFlows.ClientCredentials(
                tokenUrl: testUrl,
                refreshUrl: testUrl,
                scopes: scopes
            ),
            authorizationCode: OpenAPI.OAuthFlows.AuthorizationCode(
                authorizationUrl: testUrl,
                tokenUrl: testUrl,
                refreshUrl: testUrl,
                scopes: scopes
            ),
            deviceAuthorization: OpenAPI.OAuthFlows.DeviceAuthorization(
                deviceAuthorizationUrl: testUrl,
                tokenUrl: testUrl,
                refreshUrl: testUrl,
                scopes: scopes
            )
        )

        let encodedFlows = try orderUnstableTestStringFromEncoding(of: oauthFlows)

        assertJSONEquivalent(
            encodedFlows,
            """
            {
              "authorizationCode" : {
                "authorizationUrl" : "http:\\/\\/google.com",
                "refreshUrl" : "http:\\/\\/google.com",
                "scopes" : {
                  "read:test" : "read things",
                  "write:test" : "write things"
                },
                "tokenUrl" : "http:\\/\\/google.com"
              },
              "clientCredentials" : {
                "refreshUrl" : "http:\\/\\/google.com",
                "scopes" : {
                  "read:test" : "read things",
                  "write:test" : "write things"
                },
                "tokenUrl" : "http:\\/\\/google.com"
              },
              "deviceAuthorization" : {
                "deviceAuthorizationUrl" : "http:\\/\\/google.com",
                "refreshUrl" : "http:\\/\\/google.com",
                "scopes" : {
                  "read:test" : "read things",
                  "write:test" : "write things"
                },
                "tokenUrl" : "http:\\/\\/google.com"
              },
              "implicit" : {
                "authorizationUrl" : "http:\\/\\/google.com",
                "refreshUrl" : "http:\\/\\/google.com",
                "scopes" : {
                  "read:test" : "read things",
                  "write:test" : "write things"
                }
              },
              "password" : {
                "refreshUrl" : "http:\\/\\/google.com",
                "scopes" : {
                  "read:test" : "read things",
                  "write:test" : "write things"
                },
                "tokenUrl" : "http:\\/\\/google.com"
              }
            }
            """
            )
    }

    func test_maximal_decode() throws {
        let oauthFlowsData =
        """
        {
          "authorizationCode" : {
            "authorizationUrl" : "http://google.com",
            "refreshUrl" : "http://google.com",
            "scopes" : {
              "read:test" : "read things",
              "write:test" : "write things"
            },
            "tokenUrl" : "http://google.com"
          },
          "clientCredentials" : {
            "refreshUrl" : "http://google.com",
            "scopes" : {
              "read:test" : "read things",
              "write:test" : "write things"
            },
            "tokenUrl" : "http://google.com"
          },
          "implicit" : {
            "authorizationUrl" : "http://google.com",
            "refreshUrl" : "http://google.com",
            "scopes" : {
              "read:test" : "read things",
              "write:test" : "write things"
            }
          },
          "password" : {
            "refreshUrl" : "http://google.com",
            "scopes" : {
              "read:test" : "read things",
              "write:test" : "write things"
            },
            "tokenUrl" : "http://google.com"
          },
          "deviceAuthorization" : {
            "deviceAuthorizationUrl" : "http://google.com",
            "refreshUrl" : "http://google.com",
            "scopes" : {
              "read:test" : "read things",
              "write:test" : "write things"
            },
            "tokenUrl" : "http://google.com"
          }
        }
        """.data(using: .utf8)!

        let oauthFlows = try orderUnstableDecode(OpenAPI.OAuthFlows.self, from: oauthFlowsData)

        // can't compare whole object because of ordering of the ordered dictionary

        XCTAssertEqual(oauthFlows.implicit?.authorizationUrl, testUrl)
        XCTAssertEqual(oauthFlows.implicit?.refreshUrl, testUrl)
        XCTAssertEqual(oauthFlows.implicit?.scopes["read:test"], "read things")
        XCTAssertEqual(oauthFlows.implicit?.scopes["write:test"], "write things")

        XCTAssertEqual(oauthFlows.password?.tokenUrl, testUrl)
        XCTAssertEqual(oauthFlows.password?.refreshUrl, testUrl)
        XCTAssertEqual(oauthFlows.password?.scopes["read:test"], "read things")
        XCTAssertEqual(oauthFlows.password?.scopes["write:test"], "write things")

        XCTAssertEqual(oauthFlows.clientCredentials?.tokenUrl, testUrl)
        XCTAssertEqual(oauthFlows.clientCredentials?.refreshUrl, testUrl)
        XCTAssertEqual(oauthFlows.clientCredentials?.scopes["read:test"], "read things")
        XCTAssertEqual(oauthFlows.clientCredentials?.scopes["write:test"], "write things")

        XCTAssertEqual(oauthFlows.authorizationCode?.authorizationUrl, testUrl)
        XCTAssertEqual(oauthFlows.authorizationCode?.tokenUrl, testUrl)
        XCTAssertEqual(oauthFlows.authorizationCode?.refreshUrl, testUrl)
        XCTAssertEqual(oauthFlows.authorizationCode?.scopes["read:test"], "read things")
        XCTAssertEqual(oauthFlows.authorizationCode?.scopes["write:test"], "write things")

        XCTAssertEqual(oauthFlows.deviceAuthorization?.deviceAuthorizationUrl, testUrl)
        XCTAssertEqual(oauthFlows.deviceAuthorization?.tokenUrl, testUrl)
        XCTAssertEqual(oauthFlows.deviceAuthorization?.refreshUrl, testUrl)
        XCTAssertEqual(oauthFlows.deviceAuthorization?.scopes["read:test"], "read things")
        XCTAssertEqual(oauthFlows.deviceAuthorization?.scopes["write:test"], "write things")
    }

    func test_implicitFlow_encode() throws {
        let implicitFlow1 = OpenAPI.OAuthFlows.Implicit(
            authorizationUrl: testUrl,
            refreshUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow1 = try orderUnstableTestStringFromEncoding(of: implicitFlow1)

        assertJSONEquivalent(
            encodedFlow1,
            """
            {
              "authorizationUrl" : "http:\\/\\/google.com",
              "refreshUrl" : "http:\\/\\/google.com",
              "scopes" : {

              }
            }
            """
        )

        let implicitFlow2 = OpenAPI.OAuthFlows.Implicit(
            authorizationUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow2 = try orderUnstableTestStringFromEncoding(of: implicitFlow2)

        assertJSONEquivalent(
            encodedFlow2,
            """
            {
              "authorizationUrl" : "http:\\/\\/google.com",
              "scopes" : {

              }
            }
            """
        )
    }

    func test_implicitFlow_decode() throws {
        let implicitFlow1Data =
        """
        {
          "authorizationUrl" : "http:\\/\\/google.com",
          "refreshUrl" : "http:\\/\\/google.com",
          "scopes" : {

          }
        }
        """.data(using: .utf8)!

        let implicitFlow1 = try orderUnstableDecode(OpenAPI.OAuthFlows.Implicit.self, from: implicitFlow1Data)

        XCTAssertEqual(
            implicitFlow1,
            OpenAPI.OAuthFlows.Implicit(authorizationUrl: testUrl, refreshUrl: testUrl, scopes: [:])
        )

        let implicitFlow2Data =
        """
        {
          "authorizationUrl" : "http:\\/\\/google.com",
          "scopes" : {

          }
        }
        """.data(using: .utf8)!

        let implicitFlow2 = try orderUnstableDecode(OpenAPI.OAuthFlows.Implicit.self, from: implicitFlow2Data)

        XCTAssertEqual(
            implicitFlow2,
            OpenAPI.OAuthFlows.Implicit(authorizationUrl: testUrl, scopes: [:])
        )
    }

    func test_passwordFlow_encode() throws {
        let passwordFlow1 = OpenAPI.OAuthFlows.Password(
            tokenUrl: testUrl,
            refreshUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow1 = try orderUnstableTestStringFromEncoding(of: passwordFlow1)

        assertJSONEquivalent(
            encodedFlow1,
            """
            {
              "refreshUrl" : "http:\\/\\/google.com",
              "scopes" : {

              },
              "tokenUrl" : "http:\\/\\/google.com"
            }
            """
        )

        let passwordFlow2 = OpenAPI.OAuthFlows.Password(
            tokenUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow2 = try orderUnstableTestStringFromEncoding(of: passwordFlow2)

        assertJSONEquivalent(
            encodedFlow2,
            """
            {
              "scopes" : {

              },
              "tokenUrl" : "http:\\/\\/google.com"
            }
            """
        )
    }

    func test_passwordFlow_decode() throws {
        let passwordFlow1Data =
        """
        {
          "refreshUrl" : "http:\\/\\/google.com",
          "scopes" : {

          },
          "tokenUrl" : "http:\\/\\/google.com"
        }
        """.data(using: .utf8)!

        let passwordFlow1 = try orderUnstableDecode(OpenAPI.OAuthFlows.Password.self, from: passwordFlow1Data)

        XCTAssertEqual(
            passwordFlow1,
            OpenAPI.OAuthFlows.Password(tokenUrl: testUrl, refreshUrl: testUrl, scopes: [:])
        )

        let passwordFlow2Data =
        """
        {
          "scopes" : {

          },
          "tokenUrl" : "http:\\/\\/google.com"
        }
        """.data(using: .utf8)!

        let passwordFlow2 = try orderUnstableDecode(OpenAPI.OAuthFlows.Password.self, from: passwordFlow2Data)

        XCTAssertEqual(
            passwordFlow2,
            OpenAPI.OAuthFlows.Password(tokenUrl: testUrl, scopes: [:])
        )
    }

    func test_clientCredentialsFlow_encode() throws {
        let credentialsFlow1 = OpenAPI.OAuthFlows.ClientCredentials(
            tokenUrl: testUrl,
            refreshUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow1 = try orderUnstableTestStringFromEncoding(of: credentialsFlow1)

        assertJSONEquivalent(
            encodedFlow1,
            """
            {
              "refreshUrl" : "http:\\/\\/google.com",
              "scopes" : {

              },
              "tokenUrl" : "http:\\/\\/google.com"
            }
            """
        )

        let credentialsFlow2 = OpenAPI.OAuthFlows.ClientCredentials(
            tokenUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow2 = try orderUnstableTestStringFromEncoding(of: credentialsFlow2)

        assertJSONEquivalent(
            encodedFlow2,
            """
            {
              "scopes" : {

              },
              "tokenUrl" : "http:\\/\\/google.com"
            }
            """
        )
    }

    func test_clientsideCredentialsFlow_decode() throws {
        let credentialsFlow1Data =
        """
        {
          "refreshUrl" : "http:\\/\\/google.com",
          "scopes" : {

          },
          "tokenUrl" : "http:\\/\\/google.com"
        }
        """.data(using: .utf8)!

        let credentialsFlow1 = try orderUnstableDecode(OpenAPI.OAuthFlows.ClientCredentials.self, from: credentialsFlow1Data)

        XCTAssertEqual(
            credentialsFlow1,
            OpenAPI.OAuthFlows.ClientCredentials(tokenUrl: testUrl, refreshUrl: testUrl, scopes: [:])
        )

        let credentialsFlow2Data =
        """
        {
          "scopes" : {

          },
          "tokenUrl" : "http:\\/\\/google.com"
        }
        """.data(using: .utf8)!

        let credentialsFlow2 = try orderUnstableDecode(OpenAPI.OAuthFlows.ClientCredentials.self, from: credentialsFlow2Data)

        XCTAssertEqual(
            credentialsFlow2,
            OpenAPI.OAuthFlows.ClientCredentials(tokenUrl: testUrl, scopes: [:])
        )
    }

    func test_authorizationCodeFlow_encode() throws {
        let authorizationCodeFlow1 = OpenAPI.OAuthFlows.AuthorizationCode(
            authorizationUrl: testUrl,
            tokenUrl: testUrl,
            refreshUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow1 = try orderUnstableTestStringFromEncoding(of: authorizationCodeFlow1)

        assertJSONEquivalent(
            encodedFlow1,
            """
            {
              "authorizationUrl" : "http:\\/\\/google.com",
              "refreshUrl" : "http:\\/\\/google.com",
              "scopes" : {

              },
              "tokenUrl" : "http:\\/\\/google.com"
            }
            """
        )

        let authorizationCodeFlow2 = OpenAPI.OAuthFlows.AuthorizationCode(
            authorizationUrl: testUrl,
            tokenUrl: testUrl,
            scopes: [:]
        )

        let encodedFlow2 = try orderUnstableTestStringFromEncoding(of: authorizationCodeFlow2)

        assertJSONEquivalent(
            encodedFlow2,
            """
            {
              "authorizationUrl" : "http:\\/\\/google.com",
              "scopes" : {

              },
              "tokenUrl" : "http:\\/\\/google.com"
            }
            """
        )
    }

    func test_authorizationCodeFlow_decode() throws {
        let authorizationCodeFlow1Data =
        """
        {
          "authorizationUrl" : "http:\\/\\/google.com",
          "refreshUrl" : "http:\\/\\/google.com",
          "scopes" : {

          },
          "tokenUrl" : "http:\\/\\/google.com"
        }
        """.data(using: .utf8)!

        let authorizationCodeFlow1 = try orderUnstableDecode(OpenAPI.OAuthFlows.AuthorizationCode.self, from: authorizationCodeFlow1Data)

        XCTAssertEqual(
            authorizationCodeFlow1,
            OpenAPI.OAuthFlows.AuthorizationCode(authorizationUrl: testUrl, tokenUrl: testUrl, refreshUrl: testUrl, scopes: [:])
        )

        let authorizationCodeFlow2Data =
        """
        {
          "authorizationUrl" : "http:\\/\\/google.com",
          "scopes" : {

          },
          "tokenUrl" : "http:\\/\\/google.com"
        }
        """.data(using: .utf8)!

        let authorizationCodeFlow2 = try orderUnstableDecode(OpenAPI.OAuthFlows.AuthorizationCode.self, from: authorizationCodeFlow2Data)

        XCTAssertEqual(
            authorizationCodeFlow2,
            OpenAPI.OAuthFlows.AuthorizationCode(authorizationUrl: testUrl, tokenUrl: testUrl, scopes: [:])
        )
    }
}

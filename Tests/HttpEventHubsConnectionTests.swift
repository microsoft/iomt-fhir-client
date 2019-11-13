//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble

class HttpEventHubsConnectionSpec: QuickSpec {
    override func spec() {
        describe("HttpEventHubsConnection") {
            context("send is called") {
                context("the token provider throws") {
                    let test = testObjects()
                    test.tokenProvider.getTokenReturns.append(MockError.getTokenThrows)
                    it("throws the expected error") {
                        expect { try test.connection.send(httpMessage: HttpMessage(httpBody: Data(), contentType: "TEST_TYPE"), completion: nil) }.to(throwError(MockError.getTokenThrows))
                    }
                }
                context("the upload task fails with an error") {
                    let test = testObjects()
                    test.tokenProvider.getTokenReturns.append(SecurityToken(tokenString: "value", expiresAt: Date(), audience: "audience", tokenType: "testToken"))
                    test.urlSession.uploadTaskCompletions.append((nil, error: MockError.uploadTaskError))
                    waitUntil { completed in
                        try! test.connection.send(httpMessage: HttpMessage(httpBody: Data(), contentType: "TEST_TYPE"), completion: { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("completes with the expected error") {
                                expect(error).to(matchError(MockError.uploadTaskError))
                            }
                            completed()
                        })
                    }
                }
                context("the upload task fails with a 500") {
                    let test = testObjects()
                    test.tokenProvider.getTokenReturns.append(SecurityToken(tokenString: "value", expiresAt: Date(), audience: "audience", tokenType: "testToken"))
                    let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
                    test.urlSession.uploadTaskCompletions.append((response, error: nil))
                    waitUntil { completed in
                        try! test.connection.send(httpMessage: HttpMessage(httpBody: Data(), contentType: "TEST_TYPE"), completion: { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("completes with no error") {
                                expect(error).to(beNil())
                            }
                            completed()
                        })
                    }
                }
                context("the upload task is successful") {
                    let test = testObjects()
                    test.tokenProvider.getTokenReturns.append(SecurityToken(tokenString: "tokenString", expiresAt: Date(), audience: "audience", tokenType: "testToken"))
                    let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 201, httpVersion: nil, headerFields: nil)
                    test.urlSession.uploadTaskCompletions.append((response, error: nil))
                    let expectedData = Data(base64Encoded: "TEST")!
                    waitUntil { completed in
                        try! test.connection.send(httpMessage: HttpMessage(httpBody: expectedData, contentType: "testContentType"), completion: { (success, error) in
                            it("completes successfully") {
                                expect(success).to(beTrue())
                            }
                            it("completes with no error") {
                                expect(error).to(beNil())
                            }
                            it("calls upload with the expected endpoint"){
                                expect(test.urlSession.uploadTaskParams.first?.request.url?.absoluteString) == "https://test.servicebus.windows.net/TESTPATH/messages"
                            }
                            it("calls upload with the expected method"){
                                expect(test.urlSession.uploadTaskParams.first?.request.httpMethod) == "POST"
                            }
                            it("calls upload with the expected Host header") {
                                expect(test.urlSession.uploadTaskParams.first?.request.allHTTPHeaderFields?["Host"]) == "test.servicebus.windows.net"
                            }
                            it("calls upload with the expected Content-Type header") {
                                expect(test.urlSession.uploadTaskParams.first?.request.allHTTPHeaderFields?["Content-Type"]) == "testContentType"
                            }
                            it("calls upload with the expected Authorization header") {
                                expect(test.urlSession.uploadTaskParams.first?.request.allHTTPHeaderFields?["Authorization"]) == "tokenString"
                            }
                            it("calls upload with the expected http body data") {
                                expect(test.urlSession.uploadTaskParams.first?.bodyData).to(equal(expectedData))
                            }
                            completed()
                        })
                    }
                }
            }
        }
    }
    
    private func testObjects() -> (client: IomtFhirClient, tokenProvider: MockTokenProvider, urlSession: MockURLSession, connection: HttpEventHubsConnection) {
        let client = try! IomtFhirClient.CreateFromConnectionString(connectionString: "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH")
        let tokenProvider = MockTokenProvider()
        client.tokenProvider = tokenProvider
        let connection = try! HttpEventHubsConnection(iomtFhirClient: client, partitionId: nil)
        let urlSession = MockURLSession()
        connection.session = urlSession
        return (client, tokenProvider, urlSession, connection)
    }
}

//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble

class HttpEventDataSenderSpec: QuickSpec {
    override func spec() {
        describe("HttpEventDataSender") {
            context("validateEvents is called") {
                context("with an array containing at least one message") {
                    it("returns the expected count") {
                        expect(try! HttpEventDataSender.validateEvents(eventDatas: self.eventData(count: 1))) == 1
                    }
                }
                context("with an empty array") {
                    it("throws the expected error") {
                        expect { try HttpEventDataSender.validateEvents(eventDatas: self.eventData(count: 0)) }.to(throwError(IomtFhirClientError.eventDataEmpty))
                    }
                }
            }
            context("send is called") {
                context("with one message") {
                    context("the message converter fails to convert the event data") {
                        let test = testObjects()
                        let eventData =  EventData(data: Data())
                        it("throws the expected error") {
                            expect { try test.sender.send(eventDatas: [eventData], completion: { _, _ in }) }.to(throwError(EventHubsMessageError.serializationError(reason: "")))
                        }
                    }
                    context("creating the connection fails") {
                        let test = testObjects()
                        test.connectionManager.getOrCreateReturns.append(MockError.getOrCreateThrow)
                        it("throws the expected error") {
                            expect { try test.sender.send(eventDatas: self.eventData(count: 1), completion: { _, _ in }) }.to(throwError(MockError.getOrCreateThrow))
                        }
                    }
                    context("connection send fails") {
                        let test = testObjects()
                        let connection = try! MockHttpEventHubsConnection(iomtFhirClient: test.client, partitionId: nil)
                        connection.sendCompletions.append((false, MockError.onSendError))
                        test.connectionManager.getOrCreateReturns.append(connection)
                        waitUntil { completed in
                            try! test.sender.send(eventDatas: self.eventData(count: 1), completion: { (success, error) in
                                it("completes unsuccessfully") {
                                   expect(success).to(beFalse())
                                }
                                it("completes with the expected error") {
                                    expect(error).to(matchError(MockError.onSendError))
                                }
                                completed()
                            })
                        }
                    }
                    context("connection send succeeds") {
                        let test = testObjects()
                        let connection = try! MockHttpEventHubsConnection(iomtFhirClient: test.client, partitionId: nil)
                        connection.sendCompletions.append((true, nil))
                        test.connectionManager.getOrCreateReturns.append(connection)
                        waitUntil { completed in
                            try! test.sender.send(eventDatas: self.eventData(count: 1), completion: { (success, error) in
                                it("completes successfully") {
                                    expect(success).to(beTrue())
                                }
                                it("completes with no error") {
                                    expect(error).to(beNil())
                                }
                                it("calls the connection with the expected message") {
                                    let message = connection.sendParams.first
                                    expect(message?.contentType) == "application/vnd.microsoft.servicebus.json"
                                    expect(String(data:message!.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"}]"
                                }
                                completed()
                            })
                        }
                    }
                }
                context("with an empty array") {
                    let test = testObjects()
                    it("throws the expected error") {
                        expect { try test.sender.send(eventDatas: [], completion: { _, _ in }) }.to(throwError(IomtFhirClientError.eventDataEmpty))
                    }
                }
                context("with multiple messages") {
                    context("connection send succeeds") {
                        let test = testObjects()
                        let connection = try! MockHttpEventHubsConnection(iomtFhirClient: test.client, partitionId: nil)
                        connection.sendCompletions.append((true, nil))
                        test.connectionManager.getOrCreateReturns.append(connection)
                        waitUntil { completed in
                            try! test.sender.send(eventDatas: self.eventData(count: 4), completion: { (success, error) in
                                it("completes successfully") {
                                    expect(success).to(beTrue())
                                }
                                it("completes with no error") {
                                    expect(error).to(beNil())
                                }
                                it("calls the connection with the expected message") {
                                    let message = connection.sendParams.first
                                    expect(message?.contentType) == "application/vnd.microsoft.servicebus.json"
                                    expect(String(data:message!.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"},{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"},{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"},{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"}]"
                                }
                                completed()
                            })
                        }
                    }
                }
            }
            context("onSend is called") {
                context("with one message") {
                    context("the message converter fails to convert the event data") {
                        let test = testObjects()
                        let eventData =  EventData(data: Data())
                        it("throws the expected error") {
                            expect { try test.sender.onSend(eventDatas: [eventData], completion: { _, _ in }) }.to(throwError(EventHubsMessageError.serializationError(reason: "")))
                        }
                    }
                    context("creating the connection fails") {
                        let test = testObjects()
                        test.connectionManager.getOrCreateReturns.append(MockError.getOrCreateThrow)
                        it("throws the expected error") {
                            expect { try test.sender.onSend(eventDatas: self.eventData(count: 1), completion: { _, _ in }) }.to(throwError(MockError.getOrCreateThrow))
                        }
                    }
                    context("connection send fails") {
                        let test = testObjects()
                        let connection = try! MockHttpEventHubsConnection(iomtFhirClient: test.client, partitionId: nil)
                        connection.sendCompletions.append((false, MockError.onSendError))
                        test.connectionManager.getOrCreateReturns.append(connection)
                        waitUntil { completed in
                            try! test.sender.onSend(eventDatas: self.eventData(count: 1), completion: { (success, error) in
                                it("completes unsuccessfully") {
                                    expect(success).to(beFalse())
                                }
                                it("completes with the expected error") {
                                    expect(error).to(matchError(MockError.onSendError))
                                }
                                completed()
                            })
                        }
                    }
                    context("connection send succeeds") {
                        let test = testObjects()
                        let connection = try! MockHttpEventHubsConnection(iomtFhirClient: test.client, partitionId: nil)
                        connection.sendCompletions.append((true, nil))
                        test.connectionManager.getOrCreateReturns.append(connection)
                        waitUntil { completed in
                            try! test.sender.onSend(eventDatas: self.eventData(count: 1), completion: { (success, error) in
                                it("completes successfully") {
                                    expect(success).to(beTrue())
                                }
                                it("completes with no error") {
                                    expect(error).to(beNil())
                                }
                                it("calls the connection with the expected message") {
                                    let message = connection.sendParams.first
                                    expect(message?.contentType) == "application/vnd.microsoft.servicebus.json"
                                    expect(String(data:message!.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"}]"
                                }
                                completed()
                            })
                        }
                    }
                }
                context("with an empty array") {
                    let test = testObjects()
                    it("throws the expected error") {
                        expect { try test.sender.onSend(eventDatas: [], completion: { _, _ in }) }.to(throwError(IomtFhirClientError.eventDataEmpty))
                    }
                }
            }
        }
    }
    
    private func testObjects() -> (connectionManager: MockConnectionManager, client: HttpIomtFhirClient, sender: HttpEventDataSender) {
        let mockConnectionManager = MockConnectionManager()
        let client = try! IomtFhirClient.CreateFromConnectionString(connectionString: "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH")
        client.connectionManager = mockConnectionManager
        let sender = HttpEventDataSender(iomtFhirClient: client)
        return (mockConnectionManager, client as! HttpIomtFhirClient, sender)
    }
    
    private func eventData(count: Int) -> [EventData] {
        var eventData = [EventData]()
        for _ in 0..<count {
            let data = "{\"valid\":\"json\"}".data(using: .utf8)!
            eventData.append(EventData(data: data))
        }
        return eventData
    }
}

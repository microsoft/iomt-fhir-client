//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble

class IomtFhirClientSpec: QuickSpec {
    override func spec() {
        describe("IomtFhirClient") {
            context("CreateFromConnectionString is called") {
                context("with an invalid connection string") {
                    it("throws the expected error") {
                        expect { _ = try IomtFhirClient.CreateFromConnectionString(connectionString: "INVALID_STRING") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "The connection string is not formatted correctly \'INVALID_STRING\'.")))
                    }
                }
                context("with a connection string using an unsupported transport type") {
                    it("throws the expected error") {
                        let connectionString = "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH;TransportType=amqps"
                        expect { _ = try IomtFhirClient.CreateFromConnectionString(connectionString: connectionString) }.to(throwError(IomtFhirClientError.unsupportedTransportType(transportType: TransportType.amqps)))
                    }
                }
                context("with a valid connection string") {
                    context("using http transport") {
                        let client = try! IomtFhirClient.CreateFromConnectionString(connectionString: "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH")
                        it("creates a client of the expected type") {
                            expect(client).to(beAKindOf(HttpIomtFhirClient.self))
                        }
                        it("creates a token provider of the expected type") {
                            expect(client.tokenProvider).to(beAKindOf(SharedAccessSignatureTokenProvider.self))
                        }
                    }
                }
            }
            context("send event data is called") {
                context("the call to the sender is successful") {
                    let test = testObjects()
                    test.sender.onSendCompletions.append((nil, true, nil))
                    let eventData = EventData(data: Data())
                    waitUntil { completed in
                        try! test.client.send(eventData: eventData, completion: { (success, error) in
                            it("completes successfully") {
                                expect(success).to(beTrue())
                            }
                            it("does not return an error") {
                                expect(error).to(beNil())
                            }
                            it("calls the sender with the event data") {
                                expect(test.sender.onSendParams.count) == 1
                                expect(test.sender.onSendParams[0][0]).to(be(eventData))
                            }
                            completed()
                        })
                    }
                }
                context("the call to the sender fails") {
                    let test = testObjects()
                    test.sender.onSendCompletions.append((nil, false, MockError.onSendError))
                    let eventData = EventData(data: Data())
                    waitUntil { completed in
                        try! test.client.send(eventData: eventData, completion: { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("returns the expected error") {
                                expect(error).to(matchError(MockError.onSendError))
                            }
                            completed()
                        })
                    }
                }
                context("the call to the sender throws") {
                    let test = testObjects()
                    test.sender.onSendCompletions.append((MockError.onSendThrow, true, nil))
                    let eventData = EventData(data: Data())
                    expect { try test.client.send(eventData: eventData, completion: { (success, error) in }) }.to(throwError(MockError.onSendThrow))
                }
            }
            context("send event datas is called") {
                context("the call to the sender is successful") {
                    let test = testObjects()
                    test.sender.onSendCompletions.append((nil, true, nil))
                    let eventData1 = EventData(data: Data())
                    let eventData2 = EventData(data: Data())
                    let eventData3 = EventData(data: Data())
                    waitUntil { completed in
                        try! test.client.send(eventDatas: [eventData1, eventData2, eventData3], completion: { (success, error) in
                            it("completes successfully") {
                                expect(success).to(beTrue())
                            }
                            it("does not return an error") {
                                expect(error).to(beNil())
                            }
                            it("calls the sender with the event data objects") {
                                expect(test.sender.onSendParams.count) == 1
                                expect(test.sender.onSendParams[0].count) == 3
                                expect(test.sender.onSendParams[0]).to(containElementSatisfying({ (eventData) -> Bool in
                                    for data in [eventData1, eventData2, eventData3] {
                                        if data.data == eventData.data {
                                            return true
                                        }
                                    }
                                    return false
                                }))
                            }
                            completed()
                        })
                    }
                }
                context("the call to the sender fails") {
                    let test = testObjects()
                    test.sender.onSendCompletions.append((nil, false, MockError.onSendError))
                    let eventData1 = EventData(data: Data())
                    let eventData2 = EventData(data: Data())
                    let eventData3 = EventData(data: Data())
                    waitUntil { completed in
                        try! test.client.send(eventDatas: [eventData1, eventData2, eventData3], completion: { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("returns the expected error") {
                                expect(error).to(matchError(MockError.onSendError))
                            }
                            completed()
                        })
                    }
                }
                context("the call to the sender throws") {
                    let test = testObjects()
                    test.sender.onSendCompletions.append((MockError.onSendThrow, true, nil))
                    let eventData1 = EventData(data: Data())
                    let eventData2 = EventData(data: Data())
                    let eventData3 = EventData(data: Data())
                    expect { try test.client.send(eventDatas: [eventData1, eventData2, eventData3], completion: { (success, error) in }) }.to(throwError(MockError.onSendThrow))
                }
            }
        }
    }
    
    private func testObjects() -> (sender: MockDataSender, client: IomtFhirClient) {
        let sender = MockDataSender()
        let client = try! IomtFhirClient.CreateFromConnectionString(connectionString: "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH")
        client.sender = sender
        return (sender, client)
    }
}

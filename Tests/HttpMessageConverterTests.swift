//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble

class HttpMessageConverterSpec: QuickSpec {
    override func spec() {
        describe("HttpMessageConverter") {
            context("EventDatasToHttpMessage is called") {
                context("with an empty array") {
                    it("throws the expected error") {
                        expect { try HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [], partitionId: nil) }.to(throwError(EventHubsMessageError.noEventData))
                    }
                }
                context("with an empty event") {
                    it("throws the expected error") {
                        expect { return try HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [EventData(data: Data())], partitionId: nil) }.to(throwError(EventHubsMessageError.serializationError(reason: "One or more event data could not be serialized.")))
                    }
                }
                context("with an event that contains invalid json") {
                    let eventData = EventData(data: "{\"valid\":\"json\"}".data(using: .utf8)!)
                    eventData.properties = ["user" : NSData()]
                    it("throws the expected error") {
                        expect { return try HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [eventData], partitionId: nil) }.to(throwError(EventHubsMessageError.serializationError(reason: "The event data could not be serialized into valid JSON.")))
                    }
                }
                context("with a single event") {
                    let message = try! HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [EventData(data: "{\"valid\":\"json\"}".data(using: .utf8)!)], partitionId: nil)
                    it("creates a message with the expected http body") {
                        expect(String(data: message.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"}]"
                    }
                    it("creates a message with the expected content type") {
                        expect(message.contentType) == "application/vnd.microsoft.servicebus.json"
                    }
                }
                context("with an event that has user properties") {
                    let eventData = EventData(data: "{\"valid\":\"json\"}".data(using: .utf8)!)
                    eventData.properties = ["user" : "property"]
                    let message = try! HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [eventData], partitionId: nil)
                    it("creates a message with the expected http body") {
                        expect(String(data: message.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"valid\\\":\\\"json\\\"}\"},{\"UserProperties\":{\"user\":\"property\"}}]"
                    }
                    it("creates a message with the expected content type") {
                        expect(message.contentType) == "application/vnd.microsoft.servicebus.json"
                    }
                }
                context("with a multiple events") {
                    let eventData1 = EventData(data: "{\"one\":\"1\"}".data(using: .utf8)!)
                    let eventData2 = EventData(data: "{\"two\":\"2\"}".data(using: .utf8)!)
                    let eventData3 = EventData(data: "{\"three\":\"3\"}".data(using: .utf8)!)
                    let message = try! HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [eventData1, eventData2, eventData3], partitionId: nil)
                    it("creates a message with the expected http body") {
                        expect(String(data: message.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"one\\\":\\\"1\\\"}\"},{\"Body\":\"{\\\"two\\\":\\\"2\\\"}\"},{\"Body\":\"{\\\"three\\\":\\\"3\\\"}\"}]"
                    }
                    it("creates a message with the expected content type") {
                        expect(message.contentType) == "application/vnd.microsoft.servicebus.json"
                    }
                }
                context("with a multiple events with user properties") {
                    let eventData1 = EventData(data: "{\"one\":\"1\"}".data(using: .utf8)!)
                    eventData1.properties = ["user1" : "property1"]
                    let eventData2 = EventData(data: "{\"two\":\"2\"}".data(using: .utf8)!)
                    eventData2.properties = ["user2" : "property2"]
                    let eventData3 = EventData(data: "{\"three\":\"3\"}".data(using: .utf8)!)
                    eventData3.properties = ["user3" : "property3"]
                    let message = try! HttpMessageConverter.EventDatasToHttpMessage(eventDatas: [eventData1, eventData2, eventData3], partitionId: nil)
                    it("creates a message with the expected http body") {
                        expect(String(data: message.httpBody, encoding: .utf8)) == "[{\"Body\":\"{\\\"one\\\":\\\"1\\\"}\"},{\"UserProperties\":{\"user1\":\"property1\"}},{\"Body\":\"{\\\"two\\\":\\\"2\\\"}\"},{\"UserProperties\":{\"user2\":\"property2\"}},{\"Body\":\"{\\\"three\\\":\\\"3\\\"}\"},{\"UserProperties\":{\"user3\":\"property3\"}}]"
                    }
                    it("creates a message with the expected content type") {
                        expect(message.contentType) == "application/vnd.microsoft.servicebus.json"
                    }
                }
            }
        }
    }
}

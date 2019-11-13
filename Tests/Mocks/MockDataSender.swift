//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockDataSender : EventDataSenderProtocol {
    public var sendParams = [[EventData]]()
    public var sendCompletions = [(throw: Error?, success: Bool, error: Error?)]()
    public var onSendParams = [[EventData]]()
    public var onSendCompletions = [(throw: Error?, success: Bool, error: Error?)]()
    
    public func send(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws {
        sendParams.append(eventDatas)
        let comp = sendCompletions.removeFirst()
        if let error = comp.throw {
            throw error
        }
        completion(comp.success, comp.error)
    }
    
    public func onSend(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws {
        onSendParams.append(eventDatas)
        let comp = onSendCompletions.removeFirst()
        if let error = comp.throw {
            throw error
        }
        completion(comp.success, comp.error)
    }
    
    public static func validateEvents(eventDatas: [EventData]) throws -> Int {
        return 1
    }
    
    
}

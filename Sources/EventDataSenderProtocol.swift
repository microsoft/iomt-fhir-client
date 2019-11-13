//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public protocol EventDataSenderProtocol
{
    func send(eventDatas: [EventData], completion: @escaping  (Bool, Error?) -> Void) throws
    
    func onSend(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws
    
    static func validateEvents(eventDatas: [EventData]) throws -> Int
}

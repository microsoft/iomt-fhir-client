//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class EventDataSender : EventDataSenderProtocol
{
    internal let iomtFhirClient: IomtFhirClient
    
    internal let partitionId: String?
    
    internal init(iomtFhirClient: IomtFhirClient, partitionId: String? = nil)
    {
        self.iomtFhirClient = iomtFhirClient
        self.partitionId = partitionId
    }
    
    internal func send(eventDatas: [EventData], completion: @escaping  (Bool, Error?) -> Void) throws
    {
        try onSend(eventDatas: eventDatas, completion: completion)
    }
    
    internal func onSend(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws
    {
        preconditionFailure("Method mus be overridden by child class.")
    }
    
    internal static func validateEvents(eventDatas: [EventData]) throws -> Int
    {
        let count = eventDatas.count
        
        if count == 0
        {
            throw IomtFhirClientError.eventDataEmpty
        }
        
        return count
    }
}

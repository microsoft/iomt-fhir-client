//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class HttpEventDataSender : EventDataSender
{
    override internal func onSend(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws
    {
        // Ensure the data is valid.
        let _ = try EventDataSender.validateEvents(eventDatas: eventDatas)
        
        // Convert to the event data to an http message.
        let message = try HttpMessageConverter.EventDatasToHttpMessage(eventDatas: eventDatas, partitionId: partitionId)
        
        // Get or create the connection and send the events.
        let connection: HttpEventHubsConnection = try iomtFhirClient.connectionManager.getOrCreate(iomtFhirClient: iomtFhirClient, partitionId: partitionId)
        try connection.send(httpMessage: message, completion: { (success, error) in completion(success, error) })
    }
}

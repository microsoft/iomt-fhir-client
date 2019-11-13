//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class HttpMessageConverter
{
    private static let bodyKey = "Body"
    private static let userPropertiesKey = "UserProperties"
    private static let brokerPropertiesKey = "BrokerProperties"
    private static let serviceBusBatchContentType = "application/vnd.microsoft.servicebus.json"
    
    internal static func EventDatasToHttpMessage(eventDatas: [EventData], partitionId: String?) throws -> HttpMessage
    {
        guard eventDatas.count > 0 else
        {
            throw EventHubsMessageError.noEventData
        }
        
        var payloadArray: [[String : Any]] = []
        
        for eventdata in eventDatas
        {
            if let dataString = String(data: eventdata.data, encoding: .utf8),
                dataString.count > 0
            {
                payloadArray.append([bodyKey : dataString])
                
                // Add user provided properties.
                if eventdata.properties.count > 0
                {
                    payloadArray.append([userPropertiesKey : eventdata.properties])
                }
            }
            else
            {
                throw EventHubsMessageError.serializationError(reason: "One or more event data could not be serialized.")
            }
        }
        
        if (JSONSerialization.isValidJSONObject(payloadArray))
        {
            if let jsonData = try? JSONSerialization.data(withJSONObject: payloadArray, options: [])
            {
                return HttpMessage(httpBody: jsonData, contentType: serviceBusBatchContentType)
            }
        }
        
        throw EventHubsMessageError.serializationError(reason: "The event data could not be serialized into valid JSON.")
    }
}

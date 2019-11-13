//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class HttpIomtFhirClient : IomtFhirClient
{
    
    /// An specific implemetation of the data sender can be provided for testing.
    public var eventDataSender: EventDataSenderProtocol?
    
    internal convenience init(connectionStringBuilder: EventHubsConnectionStringBuilder) throws
    {
        var tokenProvider: SharedAccessSignatureTokenProvider
        
        // Create the token provider
        if let sharedAccessSignature = connectionStringBuilder.sharedAccessSignature
        {
            tokenProvider = try SharedAccessSignatureTokenProvider(sharedAccessSignature: sharedAccessSignature)
        }
        else
        {
            tokenProvider = SharedAccessSignatureTokenProvider(keyName: connectionStringBuilder.sasKeyName!, sharedAccessKey: connectionStringBuilder.sasKey!)
        }
        
        try self.init(connectionStringBuilder: connectionStringBuilder, tokenProvider: tokenProvider);
    }
    
    override internal func onCreateEventSender(partitionId: String? = nil) -> EventDataSenderProtocol
    {
        if eventDataSender != nil
        {
            return eventDataSender!
        }
        
        return HttpEventDataSender(iomtFhirClient: self, partitionId: partitionId)
    }
}

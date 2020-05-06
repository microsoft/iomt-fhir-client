//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class IomtFhirClient : NSObject
{
    public let eventHubName: String?
    
    public lazy var connectionManager: ConnectionManagerProtocol =  { return ConnectionManager() }()
    
    public var tokenProvider: TokenProviderProtocol?
    
    internal let connectionStringBuilder: EventHubsConnectionStringBuilder
    
    public lazy var sender: EventDataSenderProtocol = { return onCreateEventSender() }()
    
    /// Creates a new instance of the IoMT FHIR Client using the specified connection string. You can populate the EntityPath property with the name of the Event Hub.
    ///
    /// - Parameter connectionString: The IoMT FHIR Client connection string (e.g. Endpoint=sb://{yournamespace}.servicebus.windows.net/;SharedAccessKeyName={policyname};SharedAccessKey={key};EntityPath={eventhubname}).
    /// - Returns: A new instance of IomtFhirClient configured for the given connection and transort type.
    /** - Throws: Errors thrown by CreateFromConnectionString
     
     'InvalidConnectionString' The connection string is not formatted correctly or is missing a required value.
     
     'UnsupportedTransportType' The TransportType is not supported.
     
     */
    @objc public static func CreateFromConnectionString(connectionString: String) throws -> IomtFhirClient
    {
        // Instantiate a new connection string builder.
        let connectionStringBuilder = try EventHubsConnectionStringBuilder(connectionString: connectionString);
        
        // Ensure the connection string is valid.
        try connectionStringBuilder.validate();
        
        if connectionStringBuilder.transportType == .https
        {
            return try HttpIomtFhirClient(connectionStringBuilder: connectionStringBuilder);
        }
        
        // Currently, only HTTPS is supported - throw here if another type was specified.
        throw IomtFhirClientError.unsupportedTransportType(transportType: connectionStringBuilder.transportType)
    }
    
    internal init(connectionStringBuilder: EventHubsConnectionStringBuilder, tokenProvider: TokenProviderProtocol) throws
    {
        self.connectionStringBuilder = connectionStringBuilder
        self.eventHubName = connectionStringBuilder.entityPath
        
        // Set the token provider if an instance has not already been provided.
        if self.tokenProvider == nil
        {
            self.tokenProvider = tokenProvider
        }
    }
    
    @objc public func send(eventData: EventData, completion: @escaping (Bool, Error?) -> Void) throws
    {
        try send(eventDatas: [eventData], partitionKey: nil, completion: completion)
    }
    
    @objc public func send(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws
    {
        try send(eventDatas: eventDatas, partitionKey: nil, completion: completion)
    }
    
    @objc public func send(eventDatas: [EventData], partitionKey: String?, completion: @escaping (Bool, Error?) -> Void) throws
    {
        try sender.onSend(eventDatas: eventDatas, completion: completion)
    }
    
    internal func onCreateEventSender(partitionId: String? = nil) -> EventDataSenderProtocol
    {
        preconditionFailure("Method must be overridden by child class.")
    }
}

//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class EventHubsConnectionStringBuilder
{
    private let keyValueSeparator = "="
    private let keyValuePairDelimeter = ";"
    
    private let endpointConfigName = "Endpoint"
    private let sharedAccessKeyNameConfigName = "SharedAccessKeyName"
    private let sharedAccessKeyConfigName = "SharedAccessKey"
    private let entityPathConfigName = "EntityPath"
    private let operationTimeoutConfigName = "OperationTimeout"
    private let transportTypeConfigName = "TransportType"
    private let sharedAccessSignatureConfigName = "SharedAccessSignature"
    
    public var endpoint: URL?
    
    public var sasKey: String?
    
    public var sasKeyName: String?
    
    public var sharedAccessSignature: String?
    
    public var entityPath: String?
    
    public var operationTimeout: TimeInterval?
    
    public var transportType = TransportType.https
    
    public init(connectionString: String) throws
    {
        try parseConnectionString(connectionString: connectionString)
        try validate()
    }
    
    public init(endpointAddress: URL, entityPath: String, sharedAccessKeyName: String, sharedAccessKey: String, operationTimeout: TimeInterval?) throws
    {
        self.endpoint = endpointAddress
        self.entityPath = entityPath
        self.sasKeyName = sharedAccessKeyName
        self.operationTimeout = operationTimeout
        try validate()
    }
    
    public func validate() throws
    {
        if sharedAccessSignature != nil
        {
            if sasKeyName != nil,
                sasKey != nil
            {
                throw IomtFhirClientError.invalidConnectionString(reason: "'\(sharedAccessSignatureConfigName)' cannot be specified along with '\(sharedAccessKeyNameConfigName)' or '\(sharedAccessKeyConfigName)'. '\(sharedAccessSignatureConfigName)' alone should be sufficient to Authenticate the request.")
            }
        }
        
        if sasKeyName != nil && sasKey == nil ||
            sasKeyName == nil && sasKey != nil
        {
            throw IomtFhirClientError.invalidConnectionString(reason: "Please make sure either all or none of the following arguments are defined: '\(sharedAccessKeyNameConfigName), \(sharedAccessKeyConfigName)'")
        }
    }
    
    private func parseConnectionString(connectionString: String) throws
    {
        // Split the connection string into key value pairs using ';'.
        let keyValuePairs = connectionString.components(separatedBy: keyValuePairDelimeter)
        
        var error: IomtFhirClientError?
        
        // Loop through each key value pair.
        for keyValuePair in keyValuePairs
        {
            // Split the key value pair using the first '=' (The key may contain '=')
            if let index = keyValuePair.firstIndex(of: keyValueSeparator.first!)
            {
                let key =  String(keyValuePair.prefix(upTo: index))
                let value = String(keyValuePair.suffix(from: keyValuePair.index(index, offsetBy: 1)))
                
                if key.caseInsensitiveCompare(endpointConfigName) == .orderedSame
                {
                    if let url = getEndpoint(uri: value, path: entityPath)
                    {
                        endpoint = url
                    }
                    else
                    {
                        error = IomtFhirClientError.invalidConnectionString(reason: "The '\(endpointConfigName)' parameter is invalid: '\(value)'")
                        break
                    }
                }
                else if key.caseInsensitiveCompare(entityPathConfigName) == .orderedSame
                {
                    entityPath = value
                    
                    if let uri = endpoint?.absoluteString
                    {
                        endpoint = getEndpoint(uri: uri, path: entityPath)
                    }
                }
                else if key.caseInsensitiveCompare(sharedAccessKeyNameConfigName) == .orderedSame
                {
                    sasKeyName = value
                }
                else if key.caseInsensitiveCompare(sharedAccessKeyConfigName) == .orderedSame
                {
                    sasKey = value
                }
                else if key.caseInsensitiveCompare(sharedAccessSignatureConfigName) == .orderedSame
                {
                    sharedAccessSignature = value
                }
                else if key.caseInsensitiveCompare(operationTimeoutConfigName) == .orderedSame,
                    let doubleValue = Double(value)
                {
                    operationTimeout = TimeInterval(doubleValue)
                }
                else if key.caseInsensitiveCompare(transportTypeConfigName) == .orderedSame
                {
                    if let type = TransportType(rawValue: value.lowercased())
                    {
                        transportType = type;
                    }
                    else
                    {
                        error = IomtFhirClientError.invalidConnectionString(reason: "The specified transport type is invalid '\(value)'.")
                        break
                    }
                }
                else
                {
                    error = IomtFhirClientError.invalidConnectionString(reason: "Illegal connection string parameter name '\(key)'")
                    break
                }
                
            }
            else
            {
                error = IomtFhirClientError.invalidConnectionString(reason: "The connection string is not formatted correctly '\(connectionString)'.")
                break
            }
        }
        
        if error != nil
        {
            throw error!
        }
    }
    
    private func getEndpoint(uri: String, path: String?) -> URL?
    {
        var uri = uri
        
        if uri.hasPrefix("sb://")
        {
            uri = uri.replacingOccurrences(of: "sb://", with: "https://")
        }
        
        if let path = path
        {
            if !uri.hasSuffix("/"),
                !path.hasPrefix("/")
            {
                uri.append("/")
            }
            
            uri.append(path)
            uri.append("/messages")
        }
        
        return URL(string: uri)
    }
}

//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class ConnectionManager : ConnectionManagerProtocol
{
    private var connectionMap: [String : EventHubsConnection] = [:]
    private let lock = NSObject()
    
    internal func getOrCreate<T: EventHubsConnection>(iomtFhirClient: IomtFhirClient, partitionId: String?) throws -> T
    {
        objc_sync_enter(lock)
        defer
        {
            objc_sync_exit(lock)
        }
        
        let key = String(describing: T.self)
        
        if let manager = connectionMap[key],
            manager is T
        {
            return manager as! T
        }
        
        let manager = try T.init(iomtFhirClient: iomtFhirClient, partitionId: partitionId)
        connectionMap[key] = manager
        return manager;
    }
}

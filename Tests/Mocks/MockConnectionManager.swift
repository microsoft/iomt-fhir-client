//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockConnectionManager : ConnectionManagerProtocol {
    public var getOrCreateParams = [(iomtFhirClient: IomtFhirClient, partitionId: String?)]()
    public var getOrCreateReturns = [Any]()
    
    public func getOrCreate<T>(iomtFhirClient: IomtFhirClient, partitionId: String?) throws -> T where T : EventHubsConnection {
        getOrCreateParams.append((iomtFhirClient, partitionId))
        let ret = getOrCreateReturns.removeFirst()
        if let error = ret as? Error {
            throw error
        }
        return ret as! T
    }
}

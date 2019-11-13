//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class EventHubsConnection
{
    internal let iomtFhirClient: IomtFhirClient
    
    internal let partitionId: String?
    
    internal required init(iomtFhirClient: IomtFhirClient, partitionId: String?) throws
    {
        self.iomtFhirClient = iomtFhirClient
        self.partitionId = partitionId
    }
}

//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public protocol ConnectionManagerProtocol
{
    func getOrCreate<T: EventHubsConnection>(iomtFhirClient: IomtFhirClient, partitionId: String?) throws -> T
}

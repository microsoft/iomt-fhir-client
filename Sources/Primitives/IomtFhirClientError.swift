//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum IomtFhirClientError : Error
{
    case invalidConnectionString(reason: String)
    case unsupportedTransportType(transportType: TransportType)
    case eventDataEmpty
    case unableToCreateRequest
}

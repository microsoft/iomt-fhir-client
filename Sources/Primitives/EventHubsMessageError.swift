//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum EventHubsMessageError : Error
{
    case serializationError(reason: String)
    case noEventData
}

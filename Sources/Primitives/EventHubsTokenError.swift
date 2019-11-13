//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum EventHubsTokenError : Error
{
    case invalidTokenString(tokenString: String)
    case missingTokenField(tokenField: String)
}

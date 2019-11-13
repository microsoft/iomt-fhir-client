//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class DateFactory : DateFactoryProtocol
{
    internal func now() -> Date
    {
        return Date()
    }
}

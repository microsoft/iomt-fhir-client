//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum MockError : Error {
    case onSendError
    case onSendThrow
    case getOrCreateThrow
    case getTokenThrows
    case uploadTaskError
}

//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class HttpMessage
{
    internal let httpBody: Data
    
    internal let contentType: String
    
    internal init(httpBody: Data, contentType: String)
    {
        self.httpBody = httpBody
        self.contentType = contentType
    }
}

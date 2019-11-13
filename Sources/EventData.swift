//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class EventData
{
    public var properties: [String : Any] = [:]
    
    public var data: Data
    
    public init(data: Data)
    {
        self.data = data
    }
}

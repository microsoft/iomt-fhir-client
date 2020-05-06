//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class EventData : NSObject
{
    @objc public var properties: [String : Any] = [:]
    
    @objc public var data: Data
    
    @objc public init(data: Data)
    {
        self.data = data
    }
}

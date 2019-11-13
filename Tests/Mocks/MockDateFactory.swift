//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockDateFactory : DateFactoryProtocol {
    public var nowReturns = [Date]()
    
    public func now() -> Date {
        return nowReturns.removeFirst()
    }
}

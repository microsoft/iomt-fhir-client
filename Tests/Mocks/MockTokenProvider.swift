//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockTokenProvider : TokenProviderProtocol {
    public var getTokenParams = [(appliesTo: URL, timeToLive: TimeInterval?)]()
    public var getTokenReturns = [Any]()
    
    public func getToken(appliesTo: URL, timeToLive: TimeInterval?) throws -> SecurityToken {
        getTokenParams.append((appliesTo, timeToLive))
        let ret = getTokenReturns.removeFirst()
        if let error = ret as? Error {
            throw error
        }
        return ret as! SecurityToken
    }
}

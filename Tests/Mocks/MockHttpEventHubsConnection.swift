//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class MockHttpEventHubsConnection : HttpEventHubsConnection {
    public var sendParams = [HttpMessage]()
    public var sendCompletions = [(success: Bool, error: Error?)]()
    
    open override func send(httpMessage: HttpMessage, completion: ((Bool, Error?) -> Void)?) throws {
        sendParams.append(httpMessage)
        let comp = sendCompletions.removeFirst()
        completion?(comp.success, comp.error)
    }
}

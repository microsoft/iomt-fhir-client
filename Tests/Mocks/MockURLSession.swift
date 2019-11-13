//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockURLSession : URLSession {
    public var uploadTaskParams = [(request: URLRequest, bodyData: Data?)]()
    public var uploadTaskCompletions = [(response: URLResponse?, error: Error?)]()
    
    open override func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        uploadTaskParams.append((request, bodyData))
        let comp = uploadTaskCompletions.removeFirst()
        completionHandler(nil, comp.response, comp.error)
        return MockURLSessionUploadTask()
    }
}

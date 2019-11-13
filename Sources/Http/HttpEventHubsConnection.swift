//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal class HttpEventHubsConnection : EventHubsConnection
{
    internal var session = URLSession.shared
    
    private let httpMethod = "POST"
    private let httpHeaderFieldHost = "Host"
    private let httpHeaderFieldContentType = "Content-Type"
    private let httpHeaderFieldAuthorization = "Authorization"
    
    private let endpoint: URL
    
    internal required init(iomtFhirClient: IomtFhirClient, partitionId: String?) throws
    {
        guard let endpoint = iomtFhirClient.connectionStringBuilder.endpoint else
        {
            throw IomtFhirClientError.invalidConnectionString(reason: "A valid URL could not be created using the provided connection string.")
        }
        
        self.endpoint = endpoint
        
        try super.init(iomtFhirClient: iomtFhirClient, partitionId: partitionId)
    }
    
    internal func send(httpMessage: HttpMessage, completion: ((Bool, Error?) -> Void)?) throws
    {
        let request = try generateRequest(httpMessage: httpMessage)
        let task = session.uploadTask(with: request, from: httpMessage.httpBody) { (data, response, error) in
            completion?(self.isSuccessful(response: response, error: error), error)
        }
        
        task.resume()
    }
    
    private func generateRequest(httpMessage: HttpMessage) throws -> URLRequest
    {
        var request = URLRequest(url: endpoint)
        request.httpMethod = httpMethod
        
        request.addValue(httpMessage.contentType, forHTTPHeaderField: httpHeaderFieldContentType)
        
        if let host = endpoint.host
        {
            request.addValue(host, forHTTPHeaderField: httpHeaderFieldHost)
        }
        
        if let token = try iomtFhirClient.tokenProvider?.getToken(appliesTo: endpoint, timeToLive: nil)
        {
            request.addValue(token.tokenValue, forHTTPHeaderField: httpHeaderFieldAuthorization)
        }
        
        return request
    }
    
    private func isSuccessful(response: URLResponse?, error: Error?) -> Bool
    {
        guard error == nil else
        {
            return false
        }
        
        if let httpResponse = response as? HTTPURLResponse
        {
            return httpResponse.statusCode < 300
        }
        
        return false
    }
}

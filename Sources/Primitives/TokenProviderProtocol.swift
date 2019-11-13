//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation


/// Provides interface definition of a token provider.
public protocol TokenProviderProtocol
{
    
    /// Gets a SecurityToken
    ///
    /// - Parameter appliesTo: The URI which the access token applies to.
    /// - Parameter timeToLive: The duration (from now) the token is valid. Optional - a default TTL will be assigned if a value is not provided.
    /// - Returns: A new instance of SecurityToken
    /** - Throws: Errors thrown by getToken
     
     'InvalidTokenString' The token string is not formatted correctly.
     
     'MissingTokenField' A required field to construct the token is missing.
     
     */
    func getToken(appliesTo: URL, timeToLive: TimeInterval?) throws -> SecurityToken
}

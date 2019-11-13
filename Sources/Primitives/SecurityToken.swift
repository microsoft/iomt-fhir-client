//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation


/// Provides information about a security token such as audience, expiry time, and the string token value.
public class SecurityToken
{
    
    /// Gets the actual token.
    public let tokenValue: String
    
    /// Gets the expiration time of this token.
    public let expiresAt: Date
    
    /// Gets the audience of this token.
    public let audience: String
    
    /// Gets the token type.
    public let tokenType: String
    
    
    /// Creates a new instance of the SecurityToken class.
    ///
    /// - Parameters:
    ///   - tokenString: The token
    ///   - expiresAt: The expiration time
    ///   - audience: The audience
    ///   - tokenType: The type of token
    public init(tokenString: String, expiresAt: Date, audience: String, tokenType: String)
    {
        self.tokenValue = tokenString
        self.expiresAt = expiresAt
        self.audience = audience
        self.tokenType = tokenType
    }
}

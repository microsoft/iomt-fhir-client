//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class SharedAccessSignatureToken : SecurityToken
{
    public static let sasTokenType = "servicebus.windows.net:sastoken";
    internal static let sharedAccessSignature = "SharedAccessSignature";
    internal static let signedResource = "sr";
    internal static let signature = "sig";
    internal static let signedKeyName = "skn";
    internal static let signedExpiry = "se";
    internal static let MaxKeyNameLength = 256;
    internal static let MaxKeyLength = 256;
    
    internal static let sasPairSeparator = "&";
    internal static let sasKeyValueSeparator = "=";
    
    public convenience init(tokenString: String) throws
    {
        let expiresAt = try SharedAccessSignatureToken.getExpirationDateFromToken(tokenString: tokenString)
        let audience = try SharedAccessSignatureToken.getAudienceFromToken(tokenString: tokenString)
        
        self.init(tokenString: tokenString, expiresAt: expiresAt, audience: audience, tokenType: SharedAccessSignatureToken.sasTokenType );
    }
    
    public static func validate(sharedAccessSignature: String) throws
    {
        let decodedToken = try decode(tokenString: sharedAccessSignature)
        
        guard decodedToken[signedResource] != nil else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: signedResource)
        }
        
        guard decodedToken[signature] != nil else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: signature)
        }
        
        guard decodedToken[signedExpiry] != nil else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: signedExpiry)
        }
        
        guard decodedToken[signedKeyName] != nil else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: signedKeyName)
        }
    }
    
    public static func getAudienceFromToken(tokenString: String) throws -> String
    {
        return try getTokenValue(tokenString: tokenString, field: signedResource)
    }
    
    public static func getExpirationDateFromToken(tokenString: String) throws -> Date
    {
        let expiresOn = try getTokenValue(tokenString: tokenString, field: signedExpiry)
        
        if let epochTime = TimeInterval(expiresOn)
        {
            return Date(timeIntervalSince1970: epochTime)
        }
        
        throw EventHubsTokenError.missingTokenField(tokenField: signedExpiry)
    }
    
    public static func getKeyNameFromToken(tokenString: String) throws -> String
    {
        return try getTokenValue(tokenString: tokenString, field: signedKeyName)
    }
    
    private static func getTokenValue(tokenString: String, field: String) throws -> String
    {
        let decodedToken = try decode(tokenString: tokenString)
        
        if let value = decodedToken[field]
        {
            return value
        }
        
        throw EventHubsTokenError.missingTokenField(tokenField: field)
    }
    
    private static func decode(tokenString: String) throws -> [String : String]
    {
        let prefix = "\(sharedAccessSignature) "
        
        guard tokenString.hasPrefix(prefix) else
        {
            throw EventHubsTokenError.invalidTokenString(tokenString: tokenString)
        }
        
        let tokenPairs = String(tokenString.dropFirst(prefix.count))
        
        var result: [String : String] = [:]
        
        let sasPairs = tokenPairs.components(separatedBy: sasPairSeparator)
        
        for sasPair in sasPairs
        {
            if let index = sasPair.firstIndex(of: sasKeyValueSeparator.first!)
            {
                let key =  String(sasPair.prefix(upTo: index))
                let value = String(sasPair.suffix(from: sasPair.index(index, offsetBy: 1)))
                
                if let decodedValue = value.removingPercentEncoding
                {
                    result[key] = decodedValue
                    continue
                }
            }
            
            throw EventHubsTokenError.invalidTokenString(tokenString: tokenString)
        }
        
        return result
    }
}

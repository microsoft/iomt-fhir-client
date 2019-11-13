//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import CommonCrypto

internal class SharedAccessSignatureTokenProvider : TokenProviderProtocol
{
    public var dateFactory: DateFactoryProtocol = DateFactory()
    
    private var keyName: String
    private var sharedAccessKey: String?
    private var tokenScope: TokenScope
    private var tokenTimeToLive: TimeInterval
    private var sharedAccessSignature: String?
    
    internal init(sharedAccessSignature: String) throws
    {
        // TODO: get scope from token string
        tokenScope = .entity
        try SharedAccessSignatureToken.validate(sharedAccessSignature: sharedAccessSignature)
        self.keyName = try SharedAccessSignatureToken.getKeyNameFromToken(tokenString: sharedAccessSignature)
        let expirationDate = try SharedAccessSignatureToken.getExpirationDateFromToken(tokenString: sharedAccessSignature)
        self.tokenTimeToLive = expirationDate.timeIntervalSince1970
        self.sharedAccessSignature = sharedAccessSignature
    }
    
    internal init(keyName: String, sharedAccessKey: String, tokenTimeToLive: TimeInterval? = nil, tokenScope: TokenScope = TokenScope.entity)
    {
        self.keyName = keyName
        self.sharedAccessKey = sharedAccessKey
        self.tokenScope = tokenScope
        self.tokenTimeToLive = tokenTimeToLive ?? TimeInterval(integerLiteral: 3600) // Default token TTL is 60 minutes
    }
    
    internal func getToken(appliesTo: URL, timeToLive: TimeInterval?) throws -> SecurityToken
    {
        if sharedAccessSignature != nil
        {
            return try SharedAccessSignatureToken(tokenString: sharedAccessSignature!)
        }
        
        if let targetUri = appliesTo.appliesToUriString(tokenScope: tokenScope, ensureTrailingSlash: true)
        {
            let tokenString = try buildSignature(keyName: keyName, sharedAccessKey: sharedAccessKey!, targetUri: targetUri, timeToLive: timeToLive ?? tokenTimeToLive)
            return try SharedAccessSignatureToken(tokenString: tokenString)
        }
        
        throw EventHubsTokenError.missingTokenField(tokenField: SharedAccessSignatureToken.signedResource)
    }
    
    private func buildSignature(keyName: String, sharedAccessKey: String, targetUri: String, timeToLive:TimeInterval) throws -> String
    {
        guard let audienceUri = targetUri.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: SharedAccessSignatureToken.signedResource)
        }
        
        guard let encodedKeyName = keyName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: SharedAccessSignatureToken.signedKeyName)
        }
        
        let expiresOn = buildExpiresOn(timeToLive: timeToLive)
        let data = "\(audienceUri)\n\(expiresOn)".lowercased()
        let signature = buildSignature(key: sharedAccessKey, data: data)
        
        guard let encodedSignature = signature.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else
        {
            throw EventHubsTokenError.missingTokenField(tokenField: SharedAccessSignatureToken.signature)
        }
        
        let pairSep = SharedAccessSignatureToken.sasPairSeparator
        let valSep = SharedAccessSignatureToken.sasKeyValueSeparator
        
        return "\(SharedAccessSignatureToken.sharedAccessSignature) \(SharedAccessSignatureToken.signedResource)\(valSep)\(audienceUri.lowercased())\(pairSep)\(SharedAccessSignatureToken.signature)\(valSep)\(encodedSignature)\(pairSep)\(SharedAccessSignatureToken.signedExpiry)\(valSep)\(expiresOn)\(pairSep)\(SharedAccessSignatureToken.signedKeyName)\(valSep)\(encodedKeyName)"
    }
    
    private func buildExpiresOn(timeToLive: TimeInterval) -> String
    {
        let now = dateFactory.now()
        let expiresOn = now.timeIntervalSince1970 + timeToLive
        
        return String(describing: Int(expiresOn));
    }
    
    private func buildSignature(key: String, data: String) -> String
    {
        let keyString = key.cString(using: .ascii)
        let keyLength = Int(key.lengthOfBytes(using: .ascii))
        
        let dataString = data.cString(using: .ascii)
        let dataLength = Int(data.lengthOfBytes(using: .ascii))
        
        let resultLength = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: resultLength)
        
        CCHmac(UInt32(kCCHmacAlgSHA256) ,keyString, keyLength, dataString, dataLength, result)
        
        let data = NSData(bytes: result, length: resultLength)
        return data.base64EncodedString()
    }
}

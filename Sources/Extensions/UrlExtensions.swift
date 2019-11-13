//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

internal extension URL
{
    func appliesToUriString(tokenScope: TokenScope, ensureTrailingSlash: Bool) -> String?
    {
        var uri = ""
        
        if let host = self.host
        {
            uri.append(host)
        }
        
        if tokenScope == .entity
        {
            if !self.path.starts(with: "/")
            {
                uri.append("/")
            }
            
            uri.append(self.path)
        }
        
        if ensureTrailingSlash,
            !uri.hasSuffix("/")
        {
            uri.append("/")
        }
        
        return uri
    }
}

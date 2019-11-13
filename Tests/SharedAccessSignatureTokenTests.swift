//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble

class SharedAccessSignatureTokenSpec: QuickSpec {
    override func spec() {
        describe("SharedAccessSignatureToken") {
            context("init is called") {
                context("with an invalid token string") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken(tokenString: "INVALID_TOKEN") }.to(throwError(EventHubsTokenError.invalidTokenString(tokenString: "INVALID_TOKEN")))
                    }
                }
                context("with a valid token string") {
                    var token: SharedAccessSignatureToken?
                    it("does not throw an error") {
                        expect { token = try SharedAccessSignatureToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&se=0&skn=signedKeyName") }.toNot(throwError())
                    }
                    it("sets the tokenValue property") {
                        expect(token?.tokenValue) == "SharedAccessSignature sr=signedResource&sig=signature&se=0&skn=signedKeyName"
                    }
                    it("sets the expiresAt property") {
                        expect(token?.expiresAt).to(equal(Date.init(timeIntervalSince1970: 0)))
                    }
                    it("sets the audience property") {
                        expect(token?.audience) == "signedResource"
                    }
                    it("sets the tokenType property") {
                        expect(token?.tokenType) == "servicebus.windows.net:sastoken"
                    }
                }
            }
            context("validate is called") {
                context("with a valid shared access signature") {
                    it("does not throw an error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sr=signedResource&sig=signature&se=0&skn=signedKeyName") }.toNot(throwError())
                    }
                }
                context("with a shared access signature missing the signed resource") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sig=signature&se=0&skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "sr")))
                    }
                }
                context("with a shared access signature missing the signature") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sr=signedResource&se=0&skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "sig")))
                    }
                }
                context("with a shared access signature missing the signed expiry") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sr=signedResource&sig=signature&skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "se")))
                    }
                }
                context("with a shared access signature missing the signed key name") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sr=signedResource&sig=signature&se=0") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "skn")))
                    }
                }
            }
            context("getAudienceFromToken is called") {
                context("with a valid token string") {
                    it("returns the expected audience") {
                        expect { return try SharedAccessSignatureToken.getAudienceFromToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&se=0&skn=signedKeyName") }.to(equal("signedResource"))
                    }
                }
                context("with a token string missing the signed resource") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.getAudienceFromToken(tokenString: "SharedAccessSignature sig=signature&se=0skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "sr")))
                    }
                }
            }
            context("getExpirationDateFromToken is called") {
                context("with a valid token string") {
                    it("returns the expected date") {
                        expect { return try SharedAccessSignatureToken.getExpirationDateFromToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&se=0&skn=signedKeyName") }.to(equal(Date.init(timeIntervalSince1970: 0)))
                    }
                }
                context("with a token string missing the signed expiry") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.getExpirationDateFromToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "se")))
                    }
                }
                context("with a token string where the signed expiry value is not numerical") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.getExpirationDateFromToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&se=Zero&skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "se")))
                    }
                }
            }
            context("getKeyNameFromToken is called") {
                context("with a valid token string") {
                    it("returns the expected signed key name") {
                        expect { return try SharedAccessSignatureToken.getKeyNameFromToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&se=0&skn=signedKeyName") }.to(equal("signedKeyName"))
                    }
                }
                context("with a token string missing the signed key name") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.getKeyNameFromToken(tokenString: "SharedAccessSignature sr=signedResource&sig=signature&se=0") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "skn")))
                    }
                }
            }
        }
    }
}

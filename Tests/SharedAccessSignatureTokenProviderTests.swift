//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble

class SharedAccessSignatureTokenProviderSpec: QuickSpec {
    override func spec() {
        describe("SharedAccessSignatureTokenProvider") {
            context("init with shared access signature is called") {
                context("with an invalid shared access signature") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureTokenProvider(sharedAccessSignature: "INVALID_TOKEN") }.to(throwError(EventHubsTokenError.invalidTokenString(tokenString: "INVALID_TOKEN")))
                    }
                }
                context("with a shared access signature missing the signed key name") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sr=signedResource&sig=signature&se=0") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "skn")))
                    }
                }
                context("with a shared access signature missing the signed expiry") {
                    it("throws the expected error") {
                        expect { try SharedAccessSignatureToken.validate(sharedAccessSignature: "SharedAccessSignature sr=signedResource&sig=signature&skn=signedKeyName") }.to(throwError(EventHubsTokenError.missingTokenField(tokenField: "se")))
                    }
                }
            }
            context ("is initialized with key name and shared access key") {
                var provider = SharedAccessSignatureTokenProvider(keyName: "keyName", sharedAccessKey: "sharedAccessKey")
                context("getToken is called") {
                    context("with a valid url") {
                        let dateFactory = MockDateFactory()
                        provider.dateFactory = dateFactory
                        let date = Date(timeIntervalSince1970: TimeInterval(1567000000))
                        dateFactory.nowReturns.append(date)
                        let token = try? provider.getToken(appliesTo: URL(string: "https://test.com/test")!, timeToLive: nil)
                        it ("provides a token with the expected tokenValue") {
                            expect(token?.tokenValue) == "SharedAccessSignature sr=test.com%2ftest%2f&sig=5YJxMk3FHCFoymb4CCeRv9AMfrFen3XV0353eiIyw5I%3D&se=1567003600&skn=keyName"
                        }
                        it ("provides a token with the expected tokenType") {
                            expect(token?.tokenType) == "servicebus.windows.net:sastoken"
                        }
                        it ("provides a token with the expected expiresAt") {
                            expect(token?.expiresAt).to(equal(date.addingTimeInterval(TimeInterval(3600))))
                        }
                        it ("provides a token with the expected audience") {
                            expect(token?.audience) == "test.com/test/"
                        }
                    }
                    context ("providing a timeToLive parameter") {
                        provider = SharedAccessSignatureTokenProvider(keyName: "keyName", sharedAccessKey: "sharedAccessKey")
                        let dateFactory = MockDateFactory()
                        provider.dateFactory = dateFactory
                        let date = Date(timeIntervalSince1970: TimeInterval(1567000000))
                        dateFactory.nowReturns.append(date)
                        let token = try? provider.getToken(appliesTo: URL(string: "https://test.com/test")!, timeToLive: TimeInterval(2400))
                        it ("provides a token with the expected expiresAt") {
                            expect(token?.expiresAt).to(equal(date.addingTimeInterval(TimeInterval(2400))))
                        }
                    }
                }
                context ("with the tokenTimeToLive parameter not the default value") {
                    context("getToken is called") {
                        provider = SharedAccessSignatureTokenProvider(keyName: "keyName", sharedAccessKey: "sharedAccessKey", tokenTimeToLive: TimeInterval(4800))
                        let dateFactory = MockDateFactory()
                        provider.dateFactory = dateFactory
                        let date = Date(timeIntervalSince1970: TimeInterval(1567000000))
                        dateFactory.nowReturns.append(date)
                        let token = try? provider.getToken(appliesTo: URL(string: "https://test.com/test")!, timeToLive: nil)
                        it ("provides a token with the expected expiresAt") {
                            expect(token?.expiresAt).to(equal(date.addingTimeInterval(TimeInterval(4800))))
                        }
                    }
                }
                context ("with the tokenScope parameter not the default value") {
                    context("getToken is called") {
                        provider = SharedAccessSignatureTokenProvider(keyName: "keyName", sharedAccessKey: "sharedAccessKey", tokenTimeToLive: nil, tokenScope: .namespace)
                        let dateFactory = MockDateFactory()
                        provider.dateFactory = dateFactory
                        let date = Date(timeIntervalSince1970: TimeInterval(1567000000))
                        dateFactory.nowReturns.append(date)
                        let token = try? provider.getToken(appliesTo: URL(string: "https://test.com/test")!, timeToLive: nil)
                        it ("provides a token with the expected audience") {
                            expect(token?.audience) == "test.com/"
                        }
                    }
                }
            }
        }
    }
}

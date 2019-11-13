//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Quick
import Nimble
import Foundation

class UrlExtensionsSpec: QuickSpec {
    override func spec() {
        describe("UrlExtensions") {
            let url = URL(string: "https://test.com/entity")
            context("appliesToUriString is called") {
                context("with an entity token scope") {
                    context("ensuring a trailng slash") {
                        it("returns the expected uri string") {
                            expect(url?.appliesToUriString(tokenScope: .entity, ensureTrailingSlash: true)) == "test.com/entity/"
                        }
                    }
                    context("not ensuring a trailng slash") {
                        it("returns the expected uri string") {
                            expect(url?.appliesToUriString(tokenScope: .entity, ensureTrailingSlash: false)) == "test.com/entity"
                        }
                    }
                }
                context("with a namespace token scope") {
                    context("ensuring a trailng slash") {
                        it("returns the expected uri string") {
                            expect(url?.appliesToUriString(tokenScope: .namespace, ensureTrailingSlash: true)) == "test.com/"
                        }
                    }
                    context("not ensuring a trailng slash") {
                        it("returns the expected uri string") {
                            expect(url?.appliesToUriString(tokenScope: .namespace, ensureTrailingSlash: false)) == "test.com"
                        }
                    }
                }
            }
        }
    }
}

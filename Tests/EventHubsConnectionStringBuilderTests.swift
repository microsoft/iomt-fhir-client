//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Quick
import Nimble

class EventHubsConnectionStringBuilderSpec: QuickSpec {
    override func spec() {
        describe("EventHubsConnectionStringBuilder") {
            context("init is called") {
                context("with a string containing a SharedAccessSignature") {
                    it("does not throw an error") {
                        expect { try EventHubsConnectionStringBuilder(connectionString: "SharedAccessSignature=TESTSAS") }.toNot(throwError())
                    }
                    context("and a SharedAccessKeyName") {
                        it("throws the expected error") {
                            expect { try EventHubsConnectionStringBuilder(connectionString: "SharedAccessSignature=TESTSAS;SharedAccessKeyName=TESTKEYNAME") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "Please make sure either all or none of the following arguments are defined: \'SharedAccessKeyName, SharedAccessKey\'")))
                        }
                    }
                    context("and a SharedAccessKey") {
                        it("throws the expected error") {
                            expect { try EventHubsConnectionStringBuilder(connectionString: "SharedAccessSignature=TESTSAS;SharedAccessKey=TESTKEY") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "Please make sure either all or none of the following arguments are defined: \'SharedAccessKeyName, SharedAccessKey\'")))
                        }
                    }
                }
                context("with a string containing a SharedAccessKeyName") {
                    it("throws the expected error") {
                        expect { try EventHubsConnectionStringBuilder(connectionString: "SharedAccessKeyName=TESTKEYNAME") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "Please make sure either all or none of the following arguments are defined: \'SharedAccessKeyName, SharedAccessKey\'")))
                    }
                    context("and a SharedAccessKey") {
                        it("does not throw an error") {
                            expect { try EventHubsConnectionStringBuilder(connectionString: "SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTKEY") }.toNot(throwError())
                        }
                    }
                }
                context("with a string containing an EntityPath") {
                    let builder = try! EventHubsConnectionStringBuilder(connectionString: "EntityPath=TESTPATH")
                    it("sets the entityPath property") {
                        expect(builder.entityPath) == "TESTPATH"
                    }
                }
                context("with a string containing an Endpoint") {
                    context("with a valid url") {
                        let builder = try! EventHubsConnectionStringBuilder(connectionString: "Endpoint=sb://test.servicebus.windows.net/")
                        it("sets the endpoint property") {
                            expect(builder.endpoint?.absoluteString) == "https://test.servicebus.windows.net/"
                        }
                        context("and an EntityPath") {
                            let builder = try! EventHubsConnectionStringBuilder(connectionString: "Endpoint=sb://test.servicebus.windows.net/;EntityPath=TESTPATH")
                            it("sets the endpoint property") {
                                expect(builder.endpoint?.absoluteString) == "https://test.servicebus.windows.net/TESTPATH/messages"
                            }
                        }
                    }
                    context("with an invalid url") {
                        it("throws with the expected error") {
                            expect { try EventHubsConnectionStringBuilder(connectionString: "Endpoint=\\") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "The \'Endpoint\' parameter is invalid: \'\\\'")))
                        }
                    }
                }
                context("with a string containing an OperationTimeout") {
                    context("with a numerical value") {
                        let builder = try! EventHubsConnectionStringBuilder(connectionString: "OperationTimeout=30")
                        it("sets the operationTimeout property") {
                            expect(builder.operationTimeout) == 30
                        }
                    }
                    context("with a non-numerical value") {
                        it("throws with the expected error") {
                            expect { try EventHubsConnectionStringBuilder(connectionString: "OperationTimeout=Thirty") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "Illegal connection string parameter name \'OperationTimeout\'")))
                        }
                    }
                }
                context("with a string containing a TransportType") {
                    context("https") {
                        let builder = try! EventHubsConnectionStringBuilder(connectionString: "TransportType=https")
                        it("sets the transportType property") {
                            expect(builder.transportType) == .https
                        }
                    }
                    context("amqps") {
                        let builder = try! EventHubsConnectionStringBuilder(connectionString: "TransportType=amqps")
                        it("sets the transportType property") {
                            expect(builder.transportType) == .amqps
                        }
                    }
                    context("unsupported transport type") {
                        it("throws with the expected error") {
                            expect { try EventHubsConnectionStringBuilder(connectionString: "TransportType=mqtt") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "The specified transport type is invalid \'mqtt\'.")))
                        }
                    }
                }
                context("with an invalid connection string") {
                    it("throws with the expected error") {
                        expect { try EventHubsConnectionStringBuilder(connectionString: "INVALID_CONNECTION_STRING") }.to(throwError(IomtFhirClientError.invalidConnectionString(reason: "The connection string is not formatted correctly \'INVALID_CONNECTION_STRING\'.")))
                    }
                }
            }
        }
    }
}

# IomtFhirClient Swift Library

[![Build Status](https://microsofthealth.visualstudio.com/Health/_apis/build/status/POET/IomtFhirClient_Daily?branchName=master)](https://microsofthealth.visualstudio.com/Health/_build/latest?definitionId=436&branchName=master)

The IomtFhirClient Swift library simplifies sending IoMT (Internet of Medical Things) data to an [IoMT FHIR Connector for Azure](https://github.com/microsoft/iomt-fhir) endpoint for persistance in a FHIR® server.

## Basic Usage

### Instantiate an IomtFhirClient

An IomtFhirClient can be instantiated using a connection string.

```swift
let iomtFhirClient = try IomtFhirClient.CreateFromConnectionString(connectionString: "YOUR_CONNECTION_STRING")
```

### Create EventData

In the example below, a simple json payload is used to create an EventData object.  

```swift
let json = "{\"eventPayload\":\"payload data\"}"

let payload = json.data(using: .utf8)

let eventData = EventData(data: payload)
```

### Send the data to the Azure Event Hub

The IomtFhirClient has methods for sending single EventHub objects or collections.

```swift
do {
    try iomtFhirClient.send(eventData: eventData) { (success, error) in
        if (success && error == nil) {
            // The event was send successfully
        } else {
            // Handle any errors
        }
    }
} catch {
    // Handle any errors
}
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

There are many other ways to contribute to the IomtFhirClient Project.

* [Submit bugs](https://github.com/microsoft/iomt-fhir-client/issues) and help us verify fixes as they are checked in.
* Review the [source code changes](https://github.com/microsoft/iomt-fhir-client/pulls).
* [Contribute bug fixes](CONTRIBUTING.md).

See [Contributing to IomtFhirClient](CONTRIBUTING.md) for more information.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

FHIR® is the registered trademark of HL7 and is used with the permission of HL7. Use of the FHIR trademark does not constitute endorsement of this product by HL7.

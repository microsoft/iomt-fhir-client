// swift-tools-version:5.0
//  Package.swift
//  AzureEventHubs
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import PackageDescription

let package = Package(
    name: "IomtFhirClient",
	platforms: [
        .iOS(.v11)
	],
    products: [
        .library(
            name: "IomtFhirClient",
            targets: ["IomtFhirClient"]),
    ],
    targets: [
        .target(
            name: "IomtFhirClient",
            path: "Sources"),
    ]
)

# GRPC HealthProvider

![Linux](https://github.com/fourplusone/swift-grpc-health-provider/workflows/Linux/badge.svg) ![macOS](https://github.com/fourplusone/swift-grpc-health-provider/workflows/macOS/badge.svg)

A convenient provider for `grpc_health.v1.health` implemented in Swift.


## Getting started

Add swift-grpc-health-provider as a dependency in your `Package.swift` file

```swift
    dependencies: [
        // ...
        .package(url:"https://github.com/fourplusone/swift-grpc-health-provider", .branch("master")),
        
    ],
    targets: [
        .target(
            // ...
            dependencies: [.product(name: "HealthProvider",package:"swift-grpc-health-provider")]),    
    ]
    
```

## Usage

Add `HealthProvider` to your GRPC Server 
```swift

import GRPC
import NIO
import HealthProvider

let healthProvider = HealthProvider()

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let server = try Server.insecure(group: group)
    .withServiceProviders([healthProvider, /* other providers */])
    .bind(host: "localhost", port: 0)
    .wait()
```

Set the health of your services

```swift
healthProvider.setHealth(status:.serving, serivce:"myService")
```

## License

This project is licensed under the MIT License. The health.proto file is license under Apache 2.0.

import PackageDescription

let package = Package(
    name: "SOAPNetwork",
    products: [
        .library(
            name: "SOAPNetwork",
            targets: ["SOAPNetwork"]
        )
    ],
    targets: [
        .target(
            name: "SOAPNetwork",
            path: "SOAPNetwork"
        )
    ]
)

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "cheers-gateway",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
        // Fluent driver for MongoDB
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "Fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
        ])
    ]
)

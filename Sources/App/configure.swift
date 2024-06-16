import NIOSSL
import Fluent
import FluentPostgresDriver
import FluentMongoDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("POSTGRES_HOST") ?? "localhost",
        port: Environment.get("POSTGRES_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("POSTGRES_USERNAME") ?? "vapor_username",
        password: Environment.get("POSTGRES_PASSWORD") ?? "vapor_password",
        database: Environment.get("POSTGRES_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    try app.databases.use(
        .mongo(connectionString: Environment.get("MONGO_CONNECTION_STRING") ?? ""),
        as: .mongo
    )
    
    
    // postgresql
    app.migrations.add(UserMigration(), to: .psql)
    app.migrations.add(AccessTokenMigration(), to: .psql)
    app.migrations.add(ChatroomMigration(), to: .psql)
    app.migrations.add(ChatroomParticipantMigration(), to: .psql)
    
    // mongo
    app.migrations.add(MessageMigration(), to: .mongo)
    
    // register routes
    try routes(app)
}

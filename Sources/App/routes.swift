import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get { req async in
        "Cheers API working successfully!"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: ChatroomController())
    try app.register(collection: ImageController())
    try app.register(collection: FriendController())
}

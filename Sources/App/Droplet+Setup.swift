@_exported import Vapor
import MongoKitten
import AuthProvider

fileprivate let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
fileprivate var auth: RouteBuilder!

extension Droplet {
    
    public var chuvaMongoDb: Database {
        let db = config.environment == .test ? "test_chuva_db" : "chuva_db"
        return try! Server("mongodb://localhost:27017")[db]
    }
    
    public var authorized: RouteBuilder {
        return auth
    }
    
    public func setup() throws {
        auth = grouped(tokenMiddleware)
        try setupRoutes()
    }
}

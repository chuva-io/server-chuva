@_exported import Vapor
import MongoKitten
import AuthProvider

fileprivate let _tokenMiddleware = TokenAuthenticationMiddleware(User.self)
fileprivate var _authorized: RouteBuilder!

fileprivate let _passwordMiddleware = PasswordAuthenticationMiddleware(User.self)
fileprivate var _passwordProtected: RouteBuilder!

extension Droplet {
    
    public var chuvaMongoDb: Database {
        let db = config.environment == .test ? "test_chuva_db" : "chuva_db"
        return try! Server("mongodb://localhost:27017")[db]
    }
    
    public var authorized: RouteBuilder {
        return _authorized
    }
    
    public var passwordProtected: RouteBuilder {
        return _passwordProtected
    }
    
    public func setup() throws {
        _authorized = grouped(_tokenMiddleware)
        _passwordProtected = grouped(_passwordMiddleware)
        try setupRoutes()
    }
}

@_exported import Vapor
import MongoKitten

extension Droplet {
    
    public func chuvaMongoDb() -> Database {
        let db = config.environment == .test ? "test_chuva_db" : "chuva_db"
        return try! Server("mongodb://localhost:27017")[db]
    }
    
    public func setup() throws {
        try setupRoutes()
    }
}

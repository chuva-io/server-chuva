import Foundation
@testable import App
@testable import Vapor
import XCTest
import Testing
import FluentProvider
import MongoKitten

extension Droplet {
    static func testable() throws -> Droplet {
        let config = try Config(arguments: ["vapor", "--env=test"])
        try config.setup()
        let drop = try Droplet(config)
        
        let TEST_DB = "test_chuva_db"
        let DEV_DB = "chuva_db"
        
        _ = try Server("mongodb://localhost:27017")[TEST_DB].drop()
        _ = try Server("mongodb://localhost:27017")[DEV_DB].copy(toDatabase: TEST_DB)
        _ = try Server("mongodb://localhost:27017")[TEST_DB]
            .map { try $0.remove() }
        
        try drop.setup()
        return drop
    }
    func serveInBackground() throws {
        background {
            try! self.run()
        }
        console.wait(seconds: 0.5)
    }
}

class TestCase: XCTestCase {
    override func setUp() {
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        Testing.onFail = XCTFail
    }
}

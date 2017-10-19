import Foundation
@testable import App
@testable import Vapor
import XCTest
import Testing
import FluentProvider
import MongoKitten

fileprivate let TEST_DB = "test_chuva_db"
fileprivate let DEV_DB = "chuva_db"

extension Droplet {
    static func testable() throws -> Droplet {
        let config = try Config(arguments: ["vapor", "--env=test"])
        try config.setup()
        let drop = try Droplet(config)
        
        _ = try Server("mongodb://localhost:27017")[TEST_DB].drop()
        _ = try Server("mongodb://localhost:27017")[DEV_DB].copy(toDatabase: TEST_DB)
        
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
        _ = try! Server("mongodb://localhost:27017")[TEST_DB]
            .map { try $0.remove() }
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        Testing.onFail = XCTFail
    }
    
    override func tearDown() {
        _ = try! Server("mongodb://localhost:27017")[TEST_DB]
            .map { try $0.remove() }
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        Testing.onFail = XCTFail
    }
}

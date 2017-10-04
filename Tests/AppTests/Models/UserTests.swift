import Vapor
import HTTP
import XCTest

@testable import App

class UserTests: TestCase {
    
    let drop = try! Droplet.testable()
    
    //MARK: - Tests
    
    func test_UsernameUnique() throws {
        /***** ARRANGE *****/
        let user1 = User(username: "username", password: "password")
        let user2 = User(username: "username", password: "password123")
        
        /******* ACT *******/
 
        /****** ASSERT *****/
        XCTAssertNoThrow(try user1.save())
        XCTAssertNoThrow(try User.find(user1.id))
        XCTAssertThrowsError(try user2.save())
    }
    
}

import Vapor
import HTTP
import XCTest
import Authentication

@testable import App

class UserTests: TestCase {
    
    let drop = try! Droplet.testable()
    func testUser() -> User {
        return User(username: "user", password: "pw123")
    }
    
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
    
    func test_TokenAuthenticatable() throws {
        let user = testUser()
        XCTAssertNoThrow(try user.save())
        let token = AuthToken(token: "foo", userId: user.id!)
        XCTAssertNoThrow(try token.save())
        
        XCTAssertNoThrow(try User.authenticate(Token(string: "foo")))
    }
    
    func test_BadAuthenticationTokenFails() throws {
        let user = testUser()
        XCTAssertNoThrow(try user.save())
        let token = AuthToken(token: "foo", userId: user.id!)
        XCTAssertNoThrow(try token.save())
        
        XCTAssertThrowsError(try User.authenticate(Token(string: "bar")))
    }
    
    func test_PasswordHashed() throws {
        let user = User(username: "user123", password: "pw123")
        XCTAssertNoThrow(try user.save())
        let savedUser = try User.find(user.id!)
        
        XCTAssertNotEqual(user.password, savedUser!.password)
        XCTAssertEqual(user.hashedPassword, savedUser!.password)
    }
    
    func test_PasswordAuthentication() throws {
        let user = User(username: "user123", password: "pw123")
        XCTAssertNoThrow(try user.save())
        XCTAssertNoThrow(try User.authenticate(Password(username: "user123", password: "pw123")))
    }
    
    func test_BadPasswordAuthenticationFails() throws {
        let user = User(username: "user123", password: "pw123")
        XCTAssertNoThrow(try user.save())
        XCTAssertThrowsError(try User.authenticate(Password(username: "user12", password: "pw123")))
        XCTAssertThrowsError(try User.authenticate(Password(username: "user123", password: "pw12")))
        XCTAssertThrowsError(try User.authenticate(Password(username: "", password: "")))
    }
}

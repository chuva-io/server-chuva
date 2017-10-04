import Vapor
import HTTP
import XCTest

@testable import App

class UserRequestTests: TestCase {
    
    func newTestUser(firstName: String? = "John", lastName: String? = "Doe", username: String = "jdoe123", email: String = "jdoe123@doe.org") -> User {
        return User(firstName: firstName, username: username, email: email, password: "password123")
    }

    // getting an instance of our drop with our configuration
    let drop = try! Droplet.testable()
    
    //MARK: - Tests

    func testCreateUser() throws {
        /***** ARRANGE *****/
        let user = newTestUser()
        let userJson = try user.makeJSON()
        let startUserCount = try User.all().count
        
        /******* ACT *******/
        let request = Request(method: .post,
                              uri: "/users",
                              headers: ["Content-Type": "application/json"],
                              body: try Body(userJson))
        let response = try drop.testResponse(to: request)

        
        /****** ASSERT *****/
        
        // user persisted
        XCTAssertEqual(try User.all().count, startUserCount + 1)
        
        // response is 201
        response.assertStatus(is: .created)

        // test response is json
        guard let responseJson = response.json else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
        
        // created object has id
        try response.assertJSON("_id", passes: { jsonVal in jsonVal.string != nil })
        
        // created object properties
        try response.assertJSON("firstName", equals: user.firstName)
        try response.assertJSON("lastName", equals: user.lastName)
        try response.assertJSON("username", equals: user.username)
        try response.assertJSON("email", equals: user.email)
    }
    
    func testUpdateUserFirstName() throws {
        /***** ARRANGE *****/
        let user = newTestUser()
        try user.save()
        
        let newFirstName = "New Name"
        
        /******* ACT *******/

        let request = Request(method: .patch,
                              uri: "/users/\(user.id!.string!)",
                              headers: ["Content-Type": "application/json"],
                              body: try Body(["firstName": "New Name"]))
        let response = try drop.testResponse(to: request)
        
        
        /****** ASSERT *****/
        
        // response is 200
        response.assertStatus(is: .ok)
        
        // test response is json
        guard let responseJson = response.json else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
        
        // created object properties
        try response.assertJSON("_id", equals: user.id!)
        try response.assertJSON("firstName", equals: newFirstName)
        try response.assertJSON("lastName", equals: user.lastName)
        try response.assertJSON("username", equals: user.username)
        try response.assertJSON("email", equals: user.email)
    }

    func testUpdateUserLastName() throws {
        /***** ARRANGE *****/
        
        // Objects
        let user = newTestUser()
        try user.save()
        
        // Request
        let method = Method.patch
        let endpoint = "/users/\(user.id!.string!)"
        let headers: [HeaderKey: String] = ["Content-Type": "application/json"]
        
        let newLastName = "New Name"
        let body = try Body(["lastName": "New Name"])
        
        /******* ACT *******/
        
        let request = Request(method: method,
                              uri: endpoint,
                              headers: headers,
                              body: body)
        let response = try drop.testResponse(to: request)
        
        
        /****** ASSERT *****/
        
        // response is 200
        response.assertStatus(is: .ok)
        
        // test response is json
        guard let responseJson = response.json else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
        
        // created object properties
        try response.assertJSON("_id", equals: user.id!)
        try response.assertJSON("firstName", equals: user.firstName)
        try response.assertJSON("lastName", equals: newLastName)
        try response.assertJSON("username", equals: user.username)
        try response.assertJSON("email", equals: user.email)
    }

    func testUpdateUserEmail() throws {
        /***** ARRANGE *****/
        
        // Objects
        let user = newTestUser()
        try user.save()
        
        // Request
        let method = Method.patch
        let endpoint = "/users/\(user.id!.string!)"
        let headers: [HeaderKey: String] = ["Content-Type": "application/json"]
        
        
        /* TODO
         - Assert valid email address
         */
        let newEmail = "newemail@newemail.com"
        let body = try Body(["email": "newemail@newemail.com"])
        
        /******* ACT *******/
        
        let request = Request(method: method,
                              uri: endpoint,
                              headers: headers,
                              body: body)
        let response = try drop.testResponse(to: request)
        
        
        /****** ASSERT *****/
        
        // response is 200
        response.assertStatus(is: .ok)
        
        // test response is json
        guard let responseJson = response.json else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
        
        // created object properties
        try response.assertJSON("_id", equals: user.id!)
        try response.assertJSON("firstName", equals: user.firstName)
        try response.assertJSON("lastName", equals: user.lastName)
        try response.assertJSON("username", equals: user.username)
        try response.assertJSON("email", equals: newEmail)
    }

    func testUpdateUsernameFails() throws {
        /***** ARRANGE *****/
        
        // Objects
        let user = newTestUser()
        try user.save()
        
        // Request
        let method = Method.patch
        let endpoint = "/users/\(user.id!.string!)"
        let headers: [HeaderKey: String] = ["Content-Type": "application/json"]
        
        let newUsername = "newusername"
        let body = try Body(["username": "newusername"])
        
        /******* ACT *******/
        
        let request = Request(method: method,
                              uri: endpoint,
                              headers: headers,
                              body: body)
        let response = try drop.testResponse(to: request)
        
        
        /****** ASSERT *****/
        
        // response is 403
        response.assertStatus(is: .forbidden)
        
        // test response is json
        guard let responseJson = response.json else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
    }

    func testGetUsers() throws {
        /***** ARRANGE *****/
        let user = newTestUser()
        try user.save()
        
        /******* ACT *******/
        let request = Request(method: .get,
                              uri: "/users",
                              headers: ["Content-Type": "application/json"])
        let response = try drop.testResponse(to: request)
        
        /****** ASSERT *****/
        // response is 200
        response.assertStatus(is: .ok)
        
        // test response is json
        guard let responseJson = response.json?.array else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
        
        var users: [User] = []
        for json in responseJson {
            users.append(try User(json: json))
        }
        
        XCTAssertEqual(try User.all().count, 1)
        
        let user1 = users[0]
        XCTAssertEqual(user.id, user1.id)
        XCTAssertEqual(user.firstName, user1.firstName)
        XCTAssertEqual(user.lastName, user1.lastName)
        XCTAssertEqual(user.email, user1.email)
        XCTAssertEqual(user.username, user1.username)
        
        try newTestUser().save()
        XCTAssertEqual(try User.all().count, 2)
        
        try newTestUser().save()
        XCTAssertEqual(try User.all().count, 3)
    }


}

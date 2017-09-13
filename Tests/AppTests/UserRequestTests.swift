import Vapor
import HTTP
import XCTest

@testable import App

class UserRequestTests: TestCase {

    // getting an instance of our drop with our configuration
    let drop = try! Droplet.testable()

    func testCreateUser() throws {
        let user = User(firstName: "John",
                        lastName: "Doe",
                        username: "jdoe123",
                        email: "jdoe123@doe.org")

        let userJson = try user.makeJSON()
        let requestBody = try Body(userJson)

        /// MARK: TESTING
        let request = Request(method: .post,
                          uri: "/users",
                          headers: ["Content-Type": "application/json"],
                      body: requestBody)
        let response = try drop.testResponse(to: request)

        // response is 200
        response.assertStatus(is: .ok)

        // test response is json
        guard let responseJson = response.json else {
            XCTFail("Error getting json from response: \(response)")
            return
        }
        
        try response.assertJSON("_id", passes: { jsonVal in jsonVal.string != nil })
        try response.assertJSON("firstName", equals: user.firstName)
        try response.assertJSON("lastName", equals: user.lastName)
        try response.assertJSON("username", equals: user.username)
        try response.assertJSON("email", equals: user.email)

        /// MARK: CLEANUP
        guard let userId = responseJson["_id"]?.string,
            let userToDelete = try User.find(userId) else {
            XCTFail("Error could not convert id to string OR could not find user with id from response: \(response)")
            return
        }
        try userToDelete.delete()
    }

}

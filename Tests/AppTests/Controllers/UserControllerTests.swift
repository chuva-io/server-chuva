import Vapor
import HTTP
import XCTest
import Authentication

@testable import App

class UserControllerTests: TestCase {
    
    let drop = try! Droplet.testable()
    
    func newTestUser(username: String = "jdoe123", firstName: String? = "John", lastName: String? = "Doe", email: String? = "jdoe123@doe.org", password: String = "password123") -> User {
        let user = User(username: username, password: "password123", firstName: firstName, email: email)
        try! user.save()
        return user
    }
    
    func newToken(user: User) -> AuthToken {
        let token = AuthToken(token: "token", userId: user.id!)
        return token
    }
    
    func newToken() -> AuthToken {
        let user = User(username: "generatedTestUser", password: "password123")
        try! user.save()
        
        let token = AuthToken(token: "token", userId: user.id!)
        try! token.save()
        
        return token
    }
    
    var defaultHeaders: [HeaderKey: String] {
        return ["Content-Type": "application/json"]
    }
    
    func authHeaders(token: AuthToken) -> [HeaderKey: String] {
        return ["Content-Type": "application/json",
                "Authorization": "Bearer \(token.token)"]
    }
    
    func authHeaders() -> [HeaderKey: String] {
        return authHeaders(token: newToken())
    }
    
    func badAuthHeaders() -> [HeaderKey: String] {
        return ["Content-Type": "application/json",
                "Authorization": "Bearer garbage"]
    }
    
    
    // MARK:- Tests
    // MARK:-
    
    
    // MARK: GET /users
    func test_GetUsers() throws {
        let user1 = User(username: "user1", password: "password")
        try user1.save()
        
        let user2 = User(username: "user2", password: "pw", firstName: "John", lastName: "Doe", email: "jdoe123@jdoe.com")
        try user2.save()
        
        let request = Request(method: .get,
                              uri: "/users",
                              headers: authHeaders())
        let response = try drop.testResponse(to: request)
        
        // Response is 200
        response.assertStatus(is: .ok, "Status should be 200")
        
        // Body is returned
        XCTAssertNotNil(response.body.bytes, "Response should have body")
        
        // Body is json array
        let json = try JSON(bytes: response.body.bytes!)
        XCTAssertNotNil(json.array, "Response should be json array")
        
        // Response is serializable to Users
        let serializedUsers: [User?] = json.array!.map { try? User(json: $0) }
        XCTAssertEqual(serializedUsers.count, serializedUsers.flatMap { $0 }.count, "Some objects failed to serialize")
        
        // Response count is equal to database count
        XCTAssertEqual(serializedUsers.count, try User.all().count, "Payload count does not match database count")
    }
    
    
    // MARK: GET /users/me
    
    
    // MARK: GET /users/{id}
    
    
    // MARK:-
    
    
    // MARK: POST /users
    
    
    // MARK: POST /users/signin
    
    
    // MARK:-
    
    
    // MARK: PATCH /users
    
//    func test_Post() throws {
//        /***** ARRANGE *****/
//        let user = newTestUser()
//        let userJson = try user.makeJSON()
//        let startUserCount = try User.all().count
//
//        /******* ACT *******/
//        let request = Request(method: .post,
//                              uri: "/users",
//                              headers: ["Content-Type": "application/json"],
//                              body: try Body(userJson))
//        let response = try drop.testResponse(to: request)
//
//
//        /****** ASSERT *****/
//
//        // user persisted
//        XCTAssertEqual(try User.all().count, startUserCount + 1)
//
//        // response is 201
//        response.assertStatus(is: .created)
//
//        // test response is json
//        guard let _ = response.json else {
//            XCTFail("Error getting json from response: \(response)")
//            return
//        }
//
//        // created object has id
//        try response.assertJSON("_id", passes: { jsonVal in jsonVal.string != nil })
//
//        // created object properties
//        try response.assertJSON("firstName", equals: user.firstName)
//        try response.assertJSON("lastName", equals: user.lastName)
//        try response.assertJSON("username", equals: user.username)
//        try response.assertJSON("email", equals: user.email)
//    }
    
//    func test_PatchFirstName() throws {
//        /***** ARRANGE *****/
//        let user = newTestUser()
//        try user.save()
//
//        let newFirstName = "New Name"
//
//        /******* ACT *******/
//
//        let request = Request(method: .patch,
//                              uri: "/users/\(user.id!.string!)",
//            headers: ["Content-Type": "application/json"],
//            body: try Body(["firstName": "New Name"]))
//        let response = try drop.testResponse(to: request)
//
//
//        /****** ASSERT *****/
//
//        // response is 200
//        response.assertStatus(is: .ok)
//
//        // test response is json
//        guard let _ = response.json else {
//            XCTFail("Error getting json from response: \(response)")
//            return
//        }
//
//        // created object properties
//        try response.assertJSON("_id", equals: user.id!)
//        try response.assertJSON("firstName", equals: newFirstName)
//        try response.assertJSON("lastName", equals: user.lastName)
//        try response.assertJSON("username", equals: user.username)
//        try response.assertJSON("email", equals: user.email)
//    }
    
//    func test_PatchLastName() throws {
//        /***** ARRANGE *****/
//
//        // Objects
//        let user = newTestUser()
//        try user.save()
//
//        // Request
//        let method = Method.patch
//        let endpoint = "/users/\(user.id!.string!)"
//        let headers: [HeaderKey: String] = ["Content-Type": "application/json"]
//
//        let newLastName = "New Name"
//        let body = try Body(["lastName": "New Name"])
//
//        /******* ACT *******/
//
//        let request = Request(method: method,
//                              uri: endpoint,
//                              headers: headers,
//                              body: body)
//        let response = try drop.testResponse(to: request)
//
//
//        /****** ASSERT *****/
//
//        // response is 200
//        response.assertStatus(is: .ok)
//
//        // test response is json
//        guard let _ = response.json else {
//            XCTFail("Error getting json from response: \(response)")
//            return
//        }
//
//        // created object properties
//        try response.assertJSON("_id", equals: user.id!)
//        try response.assertJSON("firstName", equals: user.firstName)
//        try response.assertJSON("lastName", equals: newLastName)
//        try response.assertJSON("username", equals: user.username)
//        try response.assertJSON("email", equals: user.email)
//    }
    
//    func test_PatchEmail() throws {
//        /***** ARRANGE *****/
//
//        // Objects
//        let user = newTestUser()
//        try user.save()
//
//        // Request
//        let method = Method.patch
//        let endpoint = "/users/\(user.id!.string!)"
//        let headers: [HeaderKey: String] = ["Content-Type": "application/json"]
//
//
//        /* TODO
//         - Assert valid email address
//         */
//        let newEmail = "newemail@newemail.com"
//        let body = try Body(["email": "newemail@newemail.com"])
//
//        /******* ACT *******/
//
//        let request = Request(method: method,
//                              uri: endpoint,
//                              headers: headers,
//                              body: body)
//        let response = try drop.testResponse(to: request)
//
//
//        /****** ASSERT *****/
//
//        // response is 200
//        response.assertStatus(is: .ok)
//
//        // test response is json
//        guard let _ = response.json else {
//            XCTFail("Error getting json from response: \(response)")
//            return
//        }
//
//        // created object properties
//        try response.assertJSON("_id", equals: user.id!)
//        try response.assertJSON("firstName", equals: user.firstName)
//        try response.assertJSON("lastName", equals: user.lastName)
//        try response.assertJSON("username", equals: user.username)
//        try response.assertJSON("email", equals: newEmail)
//    }
    
//    func test_PatchUsernameFails() throws {
//        /***** ARRANGE *****/
//
//        // Objects
//        let user = newTestUser()
//        try user.save()
//
//        // Request
//        let method = Method.patch
//        let endpoint = "/users/\(user.id!.string!)"
//        let headers: [HeaderKey: String] = ["Content-Type": "application/json"]
//
//        let body = try Body(["username": "newusername"])
//
//        /******* ACT *******/
//
//        let request = Request(method: method,
//                              uri: endpoint,
//                              headers: headers,
//                              body: body)
//        let response = try drop.testResponse(to: request)
//
//
//        /****** ASSERT *****/
//
//        // response is 403
//        response.assertStatus(is: .forbidden)
//
//        // test response is json
//        guard let _ = response.json else {
//            XCTFail("Error getting json from response: \(response)")
//            return
//        }
//    }
    
//    func test_Get() throws {
//        /***** ARRANGE *****/
//        let user = newTestUser()
//        try user.save()
//
//        /******* ACT *******/
//        let request = Request(method: .get,
//                              uri: "/users",
//                              headers: ["Content-Type": "application/json"])
//        let response = try drop.testResponse(to: request)
//
//        /****** ASSERT *****/
//        // response is 200
//        response.assertStatus(is: .ok)
//
//        // test response is json
//        guard let responseJson = response.json?.array else {
//            XCTFail("Error getting json from response: \(response)")
//            return
//        }
//
//        var users: [User] = []
//        for json in responseJson {
//            users.append(try User(json: json))
//        }
//
//        XCTAssertEqual(try User.all().count, 1)
//
//        let user1 = users[0]
//        XCTAssertEqual(user.id, user1.id)
//        XCTAssertEqual(user.firstName, user1.firstName)
//        XCTAssertEqual(user.lastName, user1.lastName)
//        XCTAssertEqual(user.email, user1.email)
//        XCTAssertEqual(user.username, user1.username)
//
//        try newTestUser().save()
//        XCTAssertEqual(try User.all().count, 2)
//
//        try newTestUser().save()
//        XCTAssertEqual(try User.all().count, 3)
//    }

    
    //MARK: - Password Authenticated
    
    // Sign in requires username and password
    func test_SignInPasswordAuthenticated() throws {
        // Create user with username and password
        let user = User(username: "user123", password: "pw123")
        XCTAssertNoThrow(try user.save())
        
        // Create request with no authentication
        let request = Request(method: .post,
                              uri: "/users/signin",
                              headers: defaultHeaders)
        let response = try drop.testResponse(to: request)
        // Assert unauthorized
        response.assertStatus(is: .unauthorized)
        
        // Create request with HTTPBasicAuth
        let auth = Data("user123:pw123".utf8).base64EncodedString()
        let authRequest = Request(method: .post,
                                  uri: "/users/signin",
                                  headers: ["Content-Type": "application/json",
                                            "Authorization": "Basic \(auth)"])
        let authResponse = try drop.testResponse(to: authRequest)
        // Assert authorized
        XCTAssertFalse(authResponse.status == .unauthorized,
                       "\(authResponse.status.statusCode) is equal to \(Status.unauthorized.statusCode)")
    }
    
    // Wrong username or password fails authentication
    func test_SignInBadPasswordAuthenticationFails() throws {
        // Create user with username and password
        let user = User(username: "user123", password: "pw123")
        XCTAssertNoThrow(try user.save())
        
        // Create request with wrong username HTTPBasicAuth parameter
        let auth1 = Data("wrong_user:pw123".utf8).base64EncodedString()
        let request1 = Request(method: .post,
                               uri: "/users/signin",
                               headers: ["Content-Type": "application/json",
                                         "Authorization": "Basic \(auth1)"])
        let response1 = try drop.testResponse(to: request1)
        // Assert unauthorized
        response1.assertStatus(is: .unauthorized)
        
        // Create request with wrong password HTTPBasicAuth parameter
        let auth2 = Data("user123:wrong_password".utf8).base64EncodedString()
        let request2 = Request(method: .post,
                               uri: "/users/signin",
                               headers: ["Content-Type": "application/json",
                                         "Authorization": "Basic \(auth2)"])
        let response2 = try drop.testResponse(to: request2)
        // Assert unauthorized
        response2.assertStatus(is: .unauthorized)
        
        // Create request with wrong username and password HTTPBasicAuth parameters
        let auth3 = Data("wrong_user:wrong_password".utf8).base64EncodedString()
        let request3 = Request(method: .post,
                               uri: "/users/signin",
                               headers: ["Content-Type": "application/json",
                                         "Authorization": "Basic \(auth3)"])
        let response3 = try drop.testResponse(to: request3)
        // Assert unauthorized
        response3.assertStatus(is: .unauthorized)
    }
    
    
    //MARK: - Token Authenticated
    
    // Test authenticated requests
    func test_AuthenticatedRequests() throws {
        typealias AuthRequest = (HTTP.Method, String)
        
        // Requests to be tested for authentication
        let authRequests: [AuthRequest] = [(.get,   "/users"),
                                           (.get,   "/users/me"),
                                           (.get,   "/users/_id"),
                                           (.post,  "/users"),
                                           (.patch, "/users")]
        
        let authHeaders = self.authHeaders()
        
        for r in authRequests {
            
            // Without Authorization header
            let request = Request(method: r.0,
                                  uri: r.1,
                                  headers: defaultHeaders)
            let response = try drop.testResponse(to: request)
            response.assertStatus(is: .unauthorized)
            
            // With good Authorization header
            let authRequest = Request(method: r.0,
                                      uri: r.1,
                                      headers: authHeaders)
            let authResponse = try drop.testResponse(to: authRequest)
            XCTAssertFalse(authResponse.status == .unauthorized)
            
            // With bad Authorization header
            let badAuthRequest = Request(method: r.0,
                                      uri: r.1,
                                      headers: badAuthHeaders())
            let badAuthResponse = try drop.testResponse(to: badAuthRequest)
            badAuthResponse.assertStatus(is: .unauthorized)
        }
    }

}

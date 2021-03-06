import Vapor
import HTTP
import XCTest
import Authentication

@testable import App

class UserControllerTests: TestCase {

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
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        // Assert unauthorized
        response?.assertStatus(is: .unauthorized)

        // Create request with HTTPBasicAuth
        let auth = Data("user123:pw123".utf8).base64EncodedString()
        let authRequest = Request(method: .post,
                                  uri: "/users/signin",
                                  headers: ["Content-Type": "application/json",
                                            "Authorization": "Basic \(auth)"])
        
        var authResponse: Response? = nil
        XCTAssertNoThrow(authResponse = try drop.testResponse(to: authRequest))
        
        // Assert authorized
        XCTAssertFalse(authResponse?.status == .unauthorized,
                       "\(String(describing: authResponse?.status.statusCode)) is equal to \(Status.unauthorized.statusCode)")
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

        // Response count is equal to database count
        XCTAssertEqual(json.array!.count, try User.all().count, "Payload count does not match database count")
    }

    func test_GetUsersProperties() throws {
        let user1 = User(username: "user1", password: "password")
        try user1.save()
        
        let user2 = User(username: "username2", password: "pw123", firstName: "fName", lastName: "lName", email: "email@email.com")
        try user2.save()
        
        let user3 = User(username: "username3", password: "pw123", email: "email@email.com")
        try user3.save()

        let request = Request(method: .get,
                               uri: "/users",
                               headers: authHeaders())
        let response = try drop.testResponse(to: request)

        // Body is json array
        let jsonArray = try JSON(bytes: response.body.bytes!).array!
        XCTAssertTrue(jsonArray.count >= 2)

        for json in jsonArray {
            // Property exists
            XCTAssertNotNil(json["id"])
            XCTAssertNotNil(json["username"])
            XCTAssertNotNil(json["firstName"])
            XCTAssertNotNil(json["lastName"])
            
            // Property does not exist
            XCTAssertNil(json["email"])
            XCTAssertNil(json["password"])
        }
    }
    
    func test_GetUsersPropertyTypes() throws {
        let user = User(username: "username123",
                        password: "password123",
                        firstName: "fName",
                        lastName: "lName",
                        email: "email@email.com")
        try user.save()
        
        let token = AuthToken(token: "token", userId: user.id!)
        try token.save()
        
        let request = Request(method: .get,
                              uri: "/users",
                              headers: authHeaders(token: token))
        let response = try drop.testResponse(to: request)
        
        // Body is json array
        let json = try JSON(bytes: response.body.bytes!).array![0]
        
        // Equal values
        XCTAssertEqual(json["id"]?.string, user.id?.string)
        XCTAssertEqual(json["username"]?.string, user.username)
        XCTAssertEqual(json["firstName"]?.string, user.firstName)
        XCTAssertEqual(json["lastName"]?.string, user.lastName)
    }


    // MARK: GET /users/me
    
    func test_GetMe() throws {
        let request = Request(method: .get,
                              uri: "/users/me",
                              headers: authHeaders())
        let response = try drop.testResponse(to: request)
        
        // Response is 200
        response.assertStatus(is: .ok, "Status should be 200")
        
        // Body is returned
        XCTAssertNotNil(response.body.bytes, "Response should have body")
        
        // Body is json
        let json = try JSON(bytes: response.body.bytes!)
        XCTAssertNil(json.array, "Response should not be json array")
    }
    
    func test_GetMeProperties() throws {
        let user = User(username: "username123",
                        password: "password123",
                        firstName: "fName",
                        lastName: "lName",
                        email: "email@email.com")
        try user.save()
        
        let token = AuthToken(token: "token", userId: user.id!)
        try token.save()
        
        let request = Request(method: .get,
                              uri: "/users/me",
                              headers: authHeaders(token: token))
        
        let response = try drop.testResponse(to: request)
        
        let json = try JSON(bytes: response.body.bytes!)
        
        // Property exists
        XCTAssertNotNil(json["id"])
        XCTAssertNotNil(json["username"])
        XCTAssertNotNil(json["firstName"])
        XCTAssertNotNil(json["lastName"])
        XCTAssertNotNil(json["email"])
        
        // Property does not exist
        XCTAssertNil(json["password"])
    }
    
    func test_GetMePropertyTypes() throws {
        let user = User(username: "username123",
                        password: "password123",
                        firstName: "fName",
                        lastName: "lName",
                        email: "email@email.com")
        try user.save()
        
        let token = AuthToken(token: "token", userId: user.id!)
        try token.save()
        
        let request = Request(method: .get,
                              uri: "/users/me",
                              headers: authHeaders(token: token))
        
        let response = try drop.testResponse(to: request)
        
        let json = try JSON(bytes: response.body.bytes!)
        
        // Equal values
        XCTAssertEqual(json["id"]?.string, user.id?.string)
        XCTAssertEqual(json["username"]?.string, user.username)
        XCTAssertEqual(json["firstName"]?.string, user.firstName)
        XCTAssertEqual(json["lastName"]?.string, user.lastName)
        XCTAssertEqual(json["email"]?.string, user.email)
    }


    // MARK: GET /users/{id}
    
    func test_GetUserById() throws {
        let user = User(username: "username123",
                        password: "password123")
        try user.save()
        
        let token = AuthToken(token: "token", userId: user.id!)
        try token.save()
        
        let request = Request(method: .get,
                              uri: "/users/\(user.id!.string!)",
                              headers: authHeaders(token: token))
        
        let response = try drop.testResponse(to: request)
        
        // Response is 200
        response.assertStatus(is: .ok, "Status should be 200")
        
        // Body is returned
        XCTAssertNotNil(response.body.bytes, "Response should have body")
        
        // Body is json
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response.body.bytes!), "Body is not json")
        XCTAssertNil(json?.array, "Response should not be json array")
    }
    
    func test_GetUserByIdProperties() throws {
        let user = User(username: "username123",
                        password: "password123")
        XCTAssertNoThrow(try user.save())
        
        let token = AuthToken(token: "token", userId: user.id!)
        XCTAssertNoThrow(try token.save())
        
        let request = Request(method: .get,
                              uri: "/users/\(user.id!.string!)",
            headers: authHeaders(token: token))
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!))
        
        // Property exists
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["username"])
        XCTAssertNotNil(json?["firstName"])
        XCTAssertNotNil(json?["lastName"])
        
        // Property does not exist
        XCTAssertNil(json?["email"])
        XCTAssertNil(json?["password"])
    }
    
    func test_GetUserByIdPropertyTypes() throws {
        let user = User(username: "username123",
                        password: "password123")
        XCTAssertNoThrow(try user.save())
        
        let token = AuthToken(token: "token", userId: user.id!)
        XCTAssertNoThrow(try token.save())
        
        let request = Request(method: .get,
                              uri: "/users/\(user.id!.string!)",
            headers: authHeaders(token: token))
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!), "Response body is not json")
        
        // Equal values
        XCTAssertEqual(json?["id"]?.string, user.id?.string)
        XCTAssertEqual(json?["username"]?.string, user.username)
        XCTAssertEqual(json?["firstName"]?.string, user.firstName)
        XCTAssertEqual(json?["lastName"]?.string, user.lastName)
    }
    

    // MARK:-


    // MARK: POST /users
    
    func test_UsernamePasswordAndEmailRequired() throws {
        let noPasswordUser = User(username: "username1",
                                  email: "email@email.com")
        
        let noEmailUser = User(username: "username2",
                               password: "password123")
        
        let noUsernameUser = User(password: "password123",
                                  email: "email@email.com")
        
        // Expected failures
        let failingUsers = [noPasswordUser, noEmailUser, noUsernameUser]
        for user in failingUsers {
            let request = Request(method: .post,
                                  uri: "/users",
                                  headers: defaultHeaders,
                                  body: try user.makeJSON().makeBody())
            var response: Response? = nil
            XCTAssertNoThrow(response = try drop.testResponse(to: request))
            response?.assertStatus(is: .badRequest, "User: \n\(user)\n stored enexpectedly")
        }
    }
    
    func test_PostUsers() throws {
        let user = User(username: "username123",
                        password: "password123",
                        email: "email@email.com")
        
        let request = Request(method: .post,
                              uri: "/users",
                              headers: defaultHeaders,
                              body: try user.makeJSON().makeBody())
        
        // Response is 201
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        response?.assertStatus(is: .created)
        
        // Response is json
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!))
        XCTAssertNil(json?.array, "Response should not be json array")
    }
    
    func test_PostUsersProperties() throws {
        let user = User(username: "username123",
                        password: "password123",
                        email: "email@email.com")
        
        let request = Request(method: .post,
                              uri: "/users",
                              headers: defaultHeaders,
                              body: try user.makeJSON().makeBody())
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        response?.assertStatus(is: .created)
        
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!))
        
        // Property exists
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["username"])
        XCTAssertNotNil(json?["firstName"])
        XCTAssertNotNil(json?["lastName"])
        XCTAssertNotNil(json?["email"])

        // Property does not exist
        XCTAssertNil(json?["password"])
    }

    // MARK: POST /users/signin
    
    func test_PostUsersSignIn() throws {
        let user = User(username: "user123", password: "pw123")
        XCTAssertNoThrow(try user.save())
        
        // Create request with HTTPBasicAuth
        let auth = Data("user123:pw123".utf8).base64EncodedString()
        let request = Request(method: .post,
                              uri: "/users/signin",
                              headers: ["Content-Type": "application/json",
                                        "Authorization": "Basic \(auth)"])
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        // Response is 200
        response?.assertStatus(is: .ok)
        
        // Response is json
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!))
        XCTAssertNil(json?.array, "Response should not be json array")
    }
    
    func test_PostUsersSignInPropertyTypes() throws {
        let user = User(username: "username123",
                        password: "password123")
        XCTAssertNoThrow(try user.save())
        
        let auth = Data("username123:password123".utf8).base64EncodedString()
        let request = Request(method: .post,
                              uri: "/users/signin",
                              headers: ["Content-Type": "application/json",
                                        "Authorization": "Basic \(auth)"])
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!), "Response body is not json")
        
        // Equal values
        XCTAssertEqual(json?["id"]?.string, user.id?.string)
        XCTAssertEqual(json?["username"]?.string, user.username)
        XCTAssertEqual(json?["firstName"]?.string, user.firstName)
        XCTAssertEqual(json?["lastName"]?.string, user.lastName)
        
        // Token provided
        XCTAssertNotNil(json?["token"]?.string, "No auth token provided")
    }
    
    func test_PostUsersSignInProperties() throws {
        let user = User(username: "username123",
                        password: "password123")
        XCTAssertNoThrow(try user.save())
        
        let auth = Data("username123:password123".utf8).base64EncodedString()
        let request = Request(method: .post,
                              uri: "/users/signin",
                              headers: ["Content-Type": "application/json",
                                        "Authorization": "Basic \(auth)"])
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!))
        
        // Property exists
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["username"])
        XCTAssertNotNil(json?["firstName"])
        XCTAssertNotNil(json?["lastName"])
        XCTAssertNotNil(json?["email"])
        XCTAssertNotNil(json?["token"])
        
        // Property does not exist
        XCTAssertNil(json?["password"])
    }
    
    func test_PostUsersSignInTokenIsValid() throws {
        let user = User(username: "username123",
                        password: "password123")
        XCTAssertNoThrow(try user.save())
        
        let auth = Data("username123:password123".utf8).base64EncodedString()
        let request = Request(method: .post,
                              uri: "/users/signin",
                              headers: ["Content-Type": "application/json",
                                        "Authorization": "Basic \(auth)"])
        
        var response: Response? = nil
        XCTAssertNoThrow(response = try drop.testResponse(to: request))
        
        var json: JSON? = nil
        XCTAssertNoThrow(json = try JSON(bytes: response!.body.bytes!))
        
        let token = json?["token"]?.string
        XCTAssertNotNil(token, "Token should not be nil")
        
        // Token authenticated request
        let tokenRequest = Request(method: .get,
                                  uri: "/users/me",
                                  headers: authHeaders(token: token!))
        let tokenResponse = try drop.testResponse(to: tokenRequest)
        XCTAssertFalse(tokenResponse.status == .unauthorized)
    }
    
    func test_PostUsersSignTwiceReturnsSameToken() throws {
        let user = User(username: "username123",
                        password: "password123")
        XCTAssertNoThrow(try user.save())
        
        let auth = Data("username123:password123".utf8).base64EncodedString()
        
        // First request
        let request1 = Request(method: .post,
                              uri: "/users/signin",
                              headers: ["Content-Type": "application/json",
                                        "Authorization": "Basic \(auth)"])
        
        var response1: Response? = nil
        XCTAssertNoThrow(response1 = try drop.testResponse(to: request1))
        
        var json1 = try JSON(bytes: response1!.body.bytes!)
        let token1 = json1["token"]?.string
        XCTAssertNotNil(token1, "Token should not be nil")
        
        // Second request
        let request2 = Request(method: .post,
                               uri: "/users/signin",
                               headers: ["Content-Type": "application/json",
                                         "Authorization": "Basic \(auth)"])
        
        var response2: Response? = nil
        XCTAssertNoThrow(response2 = try drop.testResponse(to: request2))
        
        var json2 = try JSON(bytes: response2!.body.bytes!)
        let token2 = json2["token"]?.string
        XCTAssertNotNil(token2, "Token should not be nil")
        
        // Same token
        XCTAssertEqual(token1, token2)
    }


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

    // MARK:- Helpers

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
    
    func authHeaders(token: String) -> [HeaderKey: String] {
        return ["Content-Type": "application/json",
                "Authorization": "Bearer \(token)"]
    }

    func authHeaders() -> [HeaderKey: String] {
        return authHeaders(token: newToken())
    }

    func badAuthHeaders() -> [HeaderKey: String] {
        return ["Content-Type": "application/json",
                "Authorization": "Bearer garbage"]
    }

}

import Vapor

final class UserController {
    
    static func setupRoutes(_ droplet: Droplet) {
        
        
        // MARK:-
        
        
        // MARK: GET /users
        droplet.authorized.get("users") { request in
            return try User.all().makeJSON()
        }
        
        
        // MARK: GET /users/me
        droplet.authorized.get("users/me") { request in
            return try request.authenticatedUser().makeJSON()
        }
        
        
        // MARK: GET /users/{id}
        droplet.authorized.get("users", ":id") { request in
            return ""
        }
        
        
        // MARK:-
        
        
        // MARK: POST /users
        droplet.authorized.post("users") { request in
            guard let json = request.json else {
                throw Abort(.badRequest, reason: "no json provided")
            }
            
            let user: User
            do {
                user = try User(json: json)
            }
            catch {
                throw Abort(.badRequest, reason: "bad json")
            }
            try user.save()
            
            return try Response(status: .created, json: user.makeJSON())
        }
        
        
        // MARK: POST /users/signin
        droplet.passwordProtected.post("users/signin") { request in
            return try request.authenticatedUser().makeJSON()
        }
        
        
        // MARK:-
        
        
        // MARK: PATCH /users
        droplet.authorized.patch("users") { request in
//            guard let json = request.json else {
//                throw Abort(.badRequest, reason: "no json provided")
//            }
//
//            // Constants
//            if let _: String = try json.get("username") {
//                throw Abort(.forbidden, reason: "username cannot be changed")
//            }
//
//            // Variables
//            if let firstName: String = try json.get("firstName") {
//                user.firstName = firstName
//            }
//
//            if let lastName: String = try json.get("lastName") {
//                user.lastName = lastName
//            }
//
//            if let email: String = try json.get("email") {
//                user.email = email
//            }
//
//            try user.save()
//            return try user.makeJSON()
            return ""
        }
        
        
        // MARK:-
        
    }
    
}

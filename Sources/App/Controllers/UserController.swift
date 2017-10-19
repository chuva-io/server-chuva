import Vapor

final class UserController {
    
    static func setupRoutes(_ droplet: Droplet) {
        
        // MARK: GET /users
        droplet.authorized.get("users") { request in
            let users: [JSON] = try User.all().flatMap {
                var json: JSON = try $0.makeJSON()
                json.removeKey("email")
                json.removeKey("password")
                return json
            }
            return try users.makeJSON()
        }
        
        
        // MARK: GET /users/me
        droplet.authorized.get("users/me") { request in
            var json = try request.authenticatedUser().makeJSON()
            json.removeKey("password")
            return json
        }
        
        
        // MARK: GET /users/{id}
        droplet.authorized.get("users", ":id") { request in
            guard let id = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            guard let user = try User.find(id) else {
                throw Abort.notFound
            }
            
            var json = try user.makeJSON()
            json.removeKey("email")
            json.removeKey("password")
            return json
        }
        
        
        // MARK:-
        
        
        // MARK: POST /users
        droplet.post("users") { request in
            guard let json = request.json else {
                throw Abort(.badRequest, reason: "no json provided")
            }
            
            let user: User
            do {
                guard json["email"]?.string != nil,
                    json["password"]?.string != nil,
                    json["username"]?.string != nil else {
                        throw Abort(.badRequest, reason: "bad json")
                }
                user = try User(json: json)
            }
            catch {
                throw Abort(.badRequest, reason: "bad json")
            }
            try user.save()
            
            var responseJson = try user.makeJSON()
            responseJson.removeKey("password")
            return try Response(status: .created, json: responseJson)
        }
        
        
        // MARK: POST /users/signin
        droplet.passwordProtected.post("users/signin") { request in
            var json = try request.authenticatedUser().makeJSON()
            json.removeKey("password")
            
            // Check if user has token
            if let token = try User.TokenType.makeQuery()
                .filter(User.TokenType.self, "user__id", json["id"]?.string)
                .first() {
                try json.set("token", token.token)
            }
            else {
                // Create token
                let hasher = CryptoHasher(
                    hash: .sha256,
                    encoding: .hex
                )
                
                let userIdString = try! request.authenticatedUser().id!.bytes!.makeString()
                let random = Int.random(min: 0, max: 999999)
                let digest = try! hasher.make("\(userIdString)\(random)")
                let tokenString = digest.makeString()
                
                // Save token
                let token = AuthToken(token: tokenString, userId: try request.authenticatedUser().id!)
                try token.save()
                
                try json.set("token", tokenString)
            }
            
            return try Response(status: .ok, json: json)
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
        
    }
    
}

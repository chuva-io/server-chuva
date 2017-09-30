import Vapor

final class UserController {
    
    // MARK: GET /users
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    // MARK: GET /users/{_id}
    func show(_ request: Request, user: User) throws -> ResponseRepresentable {
        return try user.makeJSON()
    }
    
    // MARK: POST /users
    func store(_ request: Request) throws -> ResponseRepresentable {
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
    
    // MARK: PATCH /users/{_id}
    func update(_ request: Request, user: User) throws -> ResponseRepresentable {
        guard let json = request.json else {
            throw Abort(.badRequest, reason: "no json provided")
        }
        
        // Constants
        if let _: String = try json.get("username") {
            throw Abort(.forbidden, reason: "username cannot be changed")
        }
        
        // Variables
        if let firstName: String = try json.get("firstName") {
            user.firstName = firstName
        }
        
        if let lastName: String = try json.get("lastName") {
            user.lastName = lastName
        }
        
        if let email: String = try json.get("email") {
            user.email = email
        }
        
        try user.save()
        return try user.makeJSON()
    }
    
    // MARK: DELETE /users/{_id}
    func destroy(_ request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .noContent)
    }
}

extension UserController: ResourceRepresentable {
    func makeResource() -> Resource<User> {
        return Resource(index: index,
                        store: store,
                        show: show,
                        update: update,
                        destroy: destroy)
    }
}

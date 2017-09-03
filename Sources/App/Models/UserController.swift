import Vapor

final class UserController {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func show(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user as! ResponseRepresentable
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        let allUsers = try User.all()
        return try allUsers.makeJSON()
    }
    
}

extension UserController: ResourceRepresentable {
    func makeResource() -> Resource<User> {
        return Resource(index: index)
    }
}

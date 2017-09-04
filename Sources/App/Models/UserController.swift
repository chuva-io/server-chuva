import Vapor

final class UserController {
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func show(_ request: Request, model: User) throws -> ResponseRepresentable {
        let user = try request.parameters.next(User.self)
        return user as! ResponseRepresentable
    }
    
    func create(_ request: Request) throws -> ResponseRepresentable {
        let user = User(firstName: "Nilson", lastName: nil)
        try user.save()
        return try User.find(user.id)?.makeJSON() ?? "error creating"
    }
    
}

extension UserController: ResourceRepresentable {
    func makeResource() -> Resource<User> {
        return Resource(index: index, store: create, show: show)
    }
}

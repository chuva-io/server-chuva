import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        let users = UserController()
        resource("users", users)

        get("hello") { request in
            return "Hello!"
        }

        get("hello", String.parameter) { request in
            let name = try request.parameters.next(String.self)
            return "Hello, \(name)!"
        }

    }
    
}

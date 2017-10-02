import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        let users = UserController()
        resource("users", users)
        
        passwordProtected.post("users/signin") { request in
            return try request.authenticatedUser().makeJSON()
        }
        
        authorized.get("users/me") { request in
            return try request.authenticatedUser().makeJSON()
        }
        
        FormController.setupRoutes(self)
        FormTemplateController.setupRoutes(self)
    }
    
}

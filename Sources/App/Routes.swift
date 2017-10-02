import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        let users = UserController()
        resource("users", users)
        
        authorized.get("me") { request in
            return try request.authenticatedUser().makeJSON()
        }
        
        FormController.setupRoutes(self)
        FormTemplateController.setupRoutes(self)
    }
    
}

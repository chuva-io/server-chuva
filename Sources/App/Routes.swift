import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        let users = UserController()
        resource("users", users)
        
        FormController.setupRoutes(self)
        FormTemplateController.setupRoutes(self)
    }
    
}

import Vapor

extension Droplet {
    func setupRoutes() throws {
        UserController.setupRoutes(self)
        FormController.setupRoutes(self)
        FormTemplateController.setupRoutes(self)
    }
}

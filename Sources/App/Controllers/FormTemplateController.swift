import Vapor
import MongoKitten

final class FormTemplateController {
    
    static func setupRoutes(_ droplet: Droplet) {
        
        droplet.get("form_templates") { request in
            let forms = try droplet.chuvaMongoDb["form_templates"].find()
            return forms.makeDocument().makeExtendedJSONString()
        }
        
        droplet.get("form_templates", ":id") { request in
            guard let id = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            guard let form = try droplet.chuvaMongoDb["form_templates"].findOne("_id" == ObjectId(id)) else {
                throw Abort.notFound
            }
            
            return form.makeExtendedJSONString()
        }
    }
    
}

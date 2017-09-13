import Vapor
import MongoKitten

final class FormController {
    
    static let db = Form.database!.driver as! MongoKitten.Database
    
    static func setupRoutes(_ droplet: Droplet) {
        
        droplet.get("forms") { request in
            let forms = try db["forms"].find()
            return forms.makeDocument().makeExtendedJSONString()
        }
        
        droplet.get("forms", ":id") { request in
            guard let id = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            guard var form = try db["forms"].findOne("_id" == ObjectId(id)) else {
                throw Abort.notFound
            }
            
            let formUserIds: [String] = Document(form["users"])!.arrayRepresentation.map { String($0)! }
            
            let users = try formUserIds.flatMap {
                try db["users"].findOne("_id" == ObjectId($0))
            }
            
            form["users"] = users
            
            return form.makeExtendedJSONString()
        }
    }
    
}

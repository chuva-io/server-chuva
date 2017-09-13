import Vapor
import MongoKitten

final class FormController {
    
    static let collection = "forms"
    
    static func setupRoutes(_ droplet: Droplet) {
        
        droplet.get(collection) { request in
            let forms = try chuvaMongoDb[collection].find()
            return forms.makeDocument().makeExtendedJSONString()
        }
        
        droplet.get(collection, ":id") { request in
            guard let id = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            guard var form = try chuvaMongoDb[collection].findOne("_id" == ObjectId(id)) else {
                throw Abort.notFound
            }
            
            let formUserIds: [String] = Document(form["users"])!.arrayRepresentation.map { String($0)! }
            
            let users = try formUserIds.flatMap {
                try chuvaMongoDb["users"].findOne("_id" == ObjectId($0))
            }
            
            form["users"] = users
            
            return form.makeExtendedJSONString()
        }
    }
    
}

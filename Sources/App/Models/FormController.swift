import Vapor
import MongoKitten

final class FormController {
    
    static let collection = "forms"
    static let results = "form_results"
    
    static func setupRoutes(_ droplet: Droplet) {
        
        // GET /forms
        droplet.get(collection) { request in
            let forms = try chuvaMongoDb[collection].find()
            return forms.makeDocument().makeExtendedJSONString()
        }
        
        // GET /forms/:id
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
        
        // GET /forms/:id/results
        droplet.get(collection, ":id", "results") { request in
            // Form id
            guard let formId = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            // Results for form id
            let form_results = try chuvaMongoDb[results].find("form" == ObjectId(formId))
            
            let expandedResults: [Document] = try form_results.makeIterator().map {
                var result = $0
                
                // Expand user objects
                let userId = ObjectId(result["user"])!
                let user = try chuvaMongoDb["users"].findOne("_id" == userId)
                result["user"] = user
                
                // Expand question objects
                var answers = Document(result["answers"])!.arrayRepresentation.map { Document($0)! }
                let form = try chuvaMongoDb["forms"].findOne("_id" == ObjectId(formId))
                answers = answers.map {
                    var answer = $0
                    let questionId = ObjectId(answer["question"])!
                    let question = Document(form?["questions"])!.arrayRepresentation
                        .flatMap { Document($0) }
                        .filter { String($0["_id"]) == questionId.hexString }
                        .first
                    answer["question"] = question
                    return answer
                }
                result["answers"] = answers
                return result
            }
            
            return expandedResults.makeDocument().makeExtendedJSONString()
        }
    }
    
}

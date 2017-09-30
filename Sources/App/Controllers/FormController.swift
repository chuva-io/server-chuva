import Vapor
import MongoKitten

final class FormController {
    
    static let collection = "forms"
    static let results = "form_results"
    
    static func setupRoutes(_ droplet: Droplet) {
        
        // GET /forms
        droplet.get(collection) { request in
            let forms = try droplet.chuvaMongoDb()[collection].find(projecting: ["questions.answer": .excluded])
            return forms.makeDocument().makeExtendedJSONString()
        }
        
//        // GET /forms/:id
//        droplet.get(collection, ":id") { request in
//            guard let id = request.parameters["id"]?.string else {
//                throw Abort.badRequest
//            }
//            return try getForm(id: id).makeExtendedJSONString()
//        }
        
        // GET /forms/:id/results
        droplet.get(collection, ":id", "results") { request in
            // Form id
            guard let formId = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            // Results for form id
            let form_results = try droplet.chuvaMongoDb()[results].find("form" == ObjectId(formId))
            
            let expandedResults: [Document] = try form_results.makeIterator().map {
                var result = $0
                
                // Expand user objects
                let userId = ObjectId(result["user"])!
                let user = try droplet.chuvaMongoDb()["users"].findOne("_id" == userId)
                result["user"] = user
                
                // Expand question objects
                var answers = Document(result["answers"])!.arrayRepresentation.map { Document($0)! }
                let form = try droplet.chuvaMongoDb()["forms"].findOne("_id" == ObjectId(formId))
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
        
        // POST /forms
        droplet.post(collection) { request in
            guard let json = request.json else {
                throw Abort(.badRequest, reason: "no json provided")
            }
            
            let form: Form
            do {
                form = try Form(json: json)
            }
            catch {
                throw Abort(.badRequest, reason: "bad json")
            }
            
            _ = try form.questions.map { try $0.save() }
            
            try form.save()
            return try form.makeJSON()
        }
    }
    
//    static func getForm(id: String) throws -> Document {
//        guard var form = try chuvaMongoDb[collection].findOne("_id" == ObjectId(id)) else {
//            throw Abort.notFound
//        }
//        let formUserIds: [String] = Document(form["users"])!.arrayRepresentation.map { String($0)! }
//        let users = try formUserIds.flatMap {
//            try chuvaMongoDb["users"].findOne("_id" == ObjectId($0))
//        }
//        form["users"] = users
//        return form
//    }
    
}

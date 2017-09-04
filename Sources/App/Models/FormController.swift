import Vapor

final class FormController {
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try Form.all().makeJSON()
    }
    
    func show(_ request: Request, model: Form) throws -> ResponseRepresentable {
        let form = try request.parameters.next(Form.self)
        return form as! ResponseRepresentable
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        var questions:[Question.Text] = []
        
        questions.append(Question.Text(title: "What is your name?",
                                       answer: nil))
        
//        questions.append(Question.Integer(title: "How old are you?",
//                                          answer: Answer.Integer(value: nil)))
//        
//        questions.append(Question.Integer(title: "How old is your dog?",
//                                          answer: Answer.Integer(value: 3)))
//        
//        questions.append(Question.SingleChoice(title: "Which hand do you write with?",
//                                               options: Set<String>(["Left", "Right"]),
//                                               answer: nil))
//        
//        questions.append(Question.MultipleChoice(title: "Which colors do you like?",
//                                               options: Set<String>(["Red", "Blue", "Green"]),
//                                               answer: Answer.MultipleChoice(value: Set<String>(["Red", "Blue"]))))
        
        
        let form = Form(title: "My First Form", questions: questions)
        try form.save()
        return try Form.find(form.id)?.makeJSON() ?? "error creating"
    }
    
}

extension FormController: ResourceRepresentable {
    func makeResource() -> Resource<Form> {
        return Resource(index: index, store: store, show: show)
    }
}

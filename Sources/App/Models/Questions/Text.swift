import FluentProvider

extension Question {
 
    final class Text: Model, TypedQuestion {
        
        let title: String
        var answer: Answer.Text?
        var type: QuestionType = .text
        
        
        init(title: String, answer: Answer.Text?) {
            self.title = title
            self.answer = answer
        }
        
        convenience init(json: JSON) throws {
            self.init(title: try json.get("title"),
                      answer: nil)
        }
        
        let storage = Storage()
        
        func makeJSON() throws -> JSON {
            var json = JSON()
            try json.set("id", id?.string)
            try json.set("title", title)
            try json.set("answer", answer)
            try json.set("type", type.rawValue)
            return json
        }
        
        init(row: Row) throws {
            title = try row.get("title")
            answer = try row.get("answer")
            let typeString: String = try row.get("type")
            if let type = QuestionType(rawValue: typeString) {
                self.type = type
            }
            else {
                fatalError()
            }
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("id", id?.string)
            try row.set("title", title)
            try row.set("answer", answer)
            try row.set("type", type.rawValue)
            return row
        }
    }

}

extension Question.Text: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.string("title")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

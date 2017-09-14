import FluentProvider

final class Form: Model, JSONConvertible {
    
    let storage = Storage()
    
    let title: String
    let questions: [BaseQuestion]
    
    init(title: String, questions: [BaseQuestion]) {
        self.title = title
        self.questions = questions
    }
    
    convenience init(json: JSON) throws {
        let questionJson: [JSON] = try json.get("questions")
        self.init(title: try json.get("title"),
                  questions: try questionJson.map { try Question.initialize(json: $0) })
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("title", title)
        try json.set("questions", questions.map { try $0.makeJSON() })
        return json
    }
    
    init(row: Row) throws {
        title = try row.get("title")
        questions = try row.get("questions")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("questions", questions)
        return row
    }
    
}

extension Form: Timestampable { }
extension Form: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string("title")
            user.custom("questions", type: "questions")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

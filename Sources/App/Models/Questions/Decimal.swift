import FluentProvider

extension Question {
    
    final class Decimal: Model, TypedQuestion {
        
        let title: String
        var answer: Answer.Decimal?
        var type: QuestionType = .decimal
        
        let storage = Storage()
        
        init(title: String, answer: Answer.Decimal?) {
            self.title = title
            self.answer = answer
        }
        
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
            type = try row.get("type")
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

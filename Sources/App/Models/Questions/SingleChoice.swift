import FluentProvider

extension Question {
    
    final class SingleChoice<T: Hashable>: Model, TypedQuestion {

        let title: String
        let options: Set<T>
        var answer: Answer.SingleChoice<T>?
        var type: QuestionType = .singleChoice
        
        
        init(title: String, options: Set<T>, answer: Answer.SingleChoice<T>?) {
            self.title = title
            self.options = options
            self.answer = answer
        }
        
        
        let storage = Storage()
        
        func makeJSON() throws -> JSON {
            var json = JSON()
            try json.set("id", id?.string)
            try json.set("title", title)
            try json.set("options", options)
            try json.set("answer", answer)
            try json.set("type", type.rawValue)
            return json
        }
        
        init(row: Row) throws {
            title = try row.get("title")
            options = try row.get("options")
            answer = try row.get("answer")
            type = try row.get("type")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("id", id?.string)
            try row.set("title", title)
            try row.set("options", options)
            try row.set("answer", answer)
            try row.set("type", type.rawValue)
            return row
        }
    }

}

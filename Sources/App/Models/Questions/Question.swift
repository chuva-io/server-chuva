import JSON

struct Question {
    enum QuestionType: String {
        case integer
        case decimal
        case text
        case singleChoice
        case multipleChoice
    }
    
    struct SerializationError: Error { }
    
    static func initialize(json: JSON) throws -> BaseQuestion {
        let typeString: String = try json.get("type")
        guard let type = QuestionType(rawValue: typeString) else {
            throw SerializationError()
        }
        
        switch type {
        case .integer:
            return try Question.Integer(json: json)
        case .decimal:
            return try Question.Decimal(json: json)
        case .text:
            return try Question.Text(json: json)
        case .singleChoice:
            return try Question.SingleChoice<String>(json: json)
        case .multipleChoice:
            return try Question.MultipleChoice<String>(json: json)
        }
    }
    
}

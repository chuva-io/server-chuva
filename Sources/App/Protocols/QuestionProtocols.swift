import FluentProvider

protocol BaseQuestion: JSONConvertible, Model {
    var title: String { get }
    var baseAnswer: BaseAnswer? { get }
}

protocol TypedQuestion: BaseQuestion {
    associatedtype AnswerType: TypedAnswer
    var answer: AnswerType? { get }
    var type: Question.QuestionType { get }
}

extension TypedQuestion {
    var baseAnswer: BaseAnswer? {
        get { return answer }
    }
}

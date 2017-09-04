import FluentProvider

protocol BaseAnswer: JSONRepresentable {
    var baseValue: Any? { get set }
}

protocol TypedAnswer: BaseAnswer {
    associatedtype Value: Hashable
    var value: Value? { get set }
    init(value: Value?)
}

extension TypedAnswer {
    var baseValue: Any? {
        set { value = newValue as? Value }
        get { return value }
    }

    init(value: Value?) {
        self.init(value: value)
        self.value = value
        self.baseValue = baseValue
    }
    
}

extension TypedAnswer where Self: Model {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("value", value)
        return json
    }
}

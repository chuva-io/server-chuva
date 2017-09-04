import FluentProvider

final class User: Model {
    
    let storage = Storage()
    
    let firstName: String
    let lastName: String?
    let age: Int?
    
    init(row: Row) throws {
        firstName = try row.get("firstName")
        lastName = try row.get("lastName")
        age = try row.get("age")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("firstName", firstName)
        try row.set("lastName", lastName)
        try row.set("age", age)
        return row
    }
    
    init(firstName: String, lastName: String?, age: Int? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
}

extension User: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("firstName", firstName)
        try json.set("lastName", lastName)
        try json.set("age", age)
        return json
    }
}

extension User: Timestampable { }
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string("firstName")
            user.string("lastName")
            user.int("age")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

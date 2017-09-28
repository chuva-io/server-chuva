import FluentProvider

final class User: Model {
    
    let storage = Storage()
    
    var firstName: String
    var lastName: String
    let username: String
    var email: String
    
    init(row: Row) throws {
        firstName = try row.get("firstName")
        lastName = try row.get("lastName")
        username = try row.get("username")
        email = try row.get("email")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("firstName", firstName)
        try row.set("lastName", lastName)
        try row.set("username", username)
        try row.set("email", email)
        return row
    }
    
    init(firstName: String, lastName: String, username: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
    }
}

extension User: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(firstName: try json.get("firstName"),
                  lastName: try json.get("lastName"),
                  username: try json.get("username"),
                  email: try json.get("email"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("_id", id?.string)
        try json.set("firstName", firstName)
        try json.set("lastName", lastName)
        try json.set("username", username)
        try json.set("email", email)

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
            user.string("username")
            user.string("email")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

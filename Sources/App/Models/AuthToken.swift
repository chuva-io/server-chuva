import FluentProvider

final class AuthToken: Model {

    let storage = Storage()

    let token: String
    let userId: Identifier

    var user: Parent<AuthToken, User> {
        return parent(id: userId)
    }

    init(row: Row) throws {
        token = try row.get("token")
        userId = try row.get("user__id")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("user__id", userId)
        return row
    }

    init(token: String, userId: Identifier) {
        self.token = token
        self.userId = userId
    }

}

extension AuthToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.string("token")
            $0.parent(User.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

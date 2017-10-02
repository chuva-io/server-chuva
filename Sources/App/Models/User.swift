import FluentProvider
import AuthProvider

final class User: Model {
    
    let storage = Storage()
    
    var firstName: String? = nil
    var lastName: String? = nil
    let username: String
    var email: String
    var password: String
    
    init(row: Row) throws {
        firstName = try row.get("firstName")
        lastName = try row.get("lastName")
        username = try row.get("username")
        email = try row.get("email")
        password = try row.get("password")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("firstName", firstName)
        try row.set("lastName", lastName)
        try row.set("username", username)
        try row.set("email", email)
        try row.set("password", hashedPassword)
        return row
    }
    
    init(id: Identifier? = nil, firstName: String? = nil, lastName: String? = nil, username: String, email: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.password = password
        self.id = id
    }
}

extension User: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(id: try json.get("id"),
                  firstName: try json.get("firstName"),
                  lastName: try json.get("lastName"),
                  username: try json.get("username"),
                  email: try json.get("email"),
                  password: try json.get("password"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
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
            user.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

//MARK: - TokenAuthenticatable
extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken
}

extension Request {
    func authenticatedUser() throws -> User {
        return try auth.assertAuthenticated()
    }
}

//MARK: - PasswordAuthenticatable
fileprivate let _hash = CryptoHasher(
    hash: .sha256,
    encoding: .hex
)
fileprivate let _passwordVerifier = Verifier()

extension User: PasswordAuthenticatable {
    
    public static var usernameKey: String {
        return "username"
    }
    
    public static var passwordKey: String {
        return "password"
    }
    
    public var hashedPassword: String? {
        let digest = try! _hash.make(password)
        return digest.makeString()
    }
    
    static var passwordVerifier: PasswordVerifier? {
        return _passwordVerifier
    }

}

fileprivate class Verifier: PasswordVerifier {
    func verify(password: Bytes, matches hash: Bytes) throws -> Bool {
        // FIX: password string appends ':'. e.g.: "password" -> ":password"
        // Drop ':'. This is a temporary fix. Should fix in public source and submit PR.
        let hackedPassword = password.makeString().dropFirst().data(using: .utf8)!.makeBytes()
        return try _hash.check(_hash.make(hackedPassword), matchesHash: hash)
    }
}

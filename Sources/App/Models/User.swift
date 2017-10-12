import FluentProvider
import AuthProvider

final class User: Model {
    
    let storage = Storage()
    
    var username: String? = nil
    var password: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var email: String? = nil
    
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
    
    init(username: String? = nil, password: String? = nil, id: Identifier? = nil, firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
        self.username = username
        self.password = password
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

extension User: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(username: try json.get("username") ?? nil,
                  password: try json.get("password") ?? nil,
                  id: try json.get("id") ?? nil,
                  firstName: try json.get("firstName") ?? nil,
                  lastName: try json.get("lastName") ?? nil,
                  email: try json.get("email") ?? nil)
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
        guard let password = password else { return nil }
        let digest = try! _hash.make(password)
        return digest.makeString()
    }
    
    static var passwordVerifier: PasswordVerifier? {
        return _passwordVerifier
    }

}

fileprivate class Verifier: PasswordVerifier {
    func verify(password: Bytes, matches hash: Bytes) throws -> Bool {
        return try _hash.check(_hash.make(password), matchesHash: hash)
    }
}

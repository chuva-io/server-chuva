import App
import MongoKitten

let config = try Config()
//let config = try Config(arguments: ["vapor", "routes"])
try config.setup()

let db = config.environment == .test ? "test_chuva_db" : "chuva_db"
let chuvaMongoDb = try! Server("mongodb://localhost:27017")[db]

let drop = try Droplet(config)
try drop.setup()
try drop.run()

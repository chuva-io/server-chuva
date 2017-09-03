import App
import MongoProvider

let config = try Config()
try config.addProvider(MongoProvider.Provider.self)
try config.setup()

let drop = try Droplet()
try drop.setup()

try drop.run()

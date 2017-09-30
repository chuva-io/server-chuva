import App

let config = try Config()
//let config = try Config(arguments: ["vapor", "routes"])
try config.setup()

let drop = try Droplet(config)
try drop.setup()
try drop.run()

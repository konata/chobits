fs = require 'fs'

os =
  readFile:(file)-> fs.readFileSync(file)

module.exports = {os}

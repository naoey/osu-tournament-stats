process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const os = require('os')

console.log('Using CPUs', os.cpus().length)

module.exports = environment.toWebpackConfig()

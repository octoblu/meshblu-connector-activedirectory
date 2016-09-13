{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-activedirectory:index')

class Connector extends EventEmitter
  constructor: ({@ActiveDirectory})->

  close: (callback) =>
    debug 'on close'
    callback()

  getUserByUsername: (username, callback) =>
    return callback new Error 'Missing required parameter: username' unless username?

    activedirectory = new @ActiveDirectory @options
    activedirectory.findUser username, (error, {mail, employeeID, displayName}={}) =>
      return callback error if error?
      return callback null, {
        email: mail
        username: employeeID
        displayName: displayName
      }

  isOnline: (callback) =>
    callback null, running: true

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

module.exports = Connector

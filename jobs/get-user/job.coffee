http = require 'http'
_    = require 'lodash'

class GetUser
  constructor: ({@connector}) ->
    throw new Error 'GetUser requires connector' unless @connector?

  do: ({data}, callback) =>
    username = _.get data, 'username'
    return callback @_userError(422, 'requires property "username"') if _.isEmpty username

    @connector.getUserByUsername username, (error, user) =>
      return callback error if error?

      {username, displayName, email} = user
      callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: {username, displayName, email}
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetUser

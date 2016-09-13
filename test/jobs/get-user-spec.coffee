{beforeEach, context, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

{job} = require '../../jobs/get-user'

describe 'DoSomething', ->
  context 'when given a valid message and the connector call succeeds', ->
    beforeEach (done) ->
      @connector = {
        getUserByUsername: sinon
          .stub()
          .withArgs('royz')
          .yields null, { username: 'royz', displayName: 'Roy Zandewager', email: 'roy.zandewager@citrix.com' }
      }
      message =
        data:
          username: 'royv'
      @sut = new job {@connector}
      @sut.do message, (@error, @response) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should respond with the user', ->
      expect(@response).to.deep.equal {
        metadata:
          code: 200
          status: 'OK'
        data:
          username: 'royz'
          displayName: 'Roy Zandewager'
          email: 'roy.zandewager@citrix.com'
      }

  context 'when given a valid message and the connector call errors', ->
    beforeEach (done) ->
      @connector = { getUserByUsername: sinon.stub().withArgs('royv').yields new Error('uh oh') }
      message =
        data:
          username: 'royv'
      @sut = new job {@connector}
      @sut.do message, (@error, @response) =>
        done()

    it 'should error', ->
      expect(@error).to.exist

  context 'when given an invalid message', ->
    beforeEach (done) ->
      @connector = {}
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should error with a 422', ->
      expect(@error).to.exist
      expect(@error.code).to.equal 422
      expect(@error.message).to.equal 'requires property "username"'

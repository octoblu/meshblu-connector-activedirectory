{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    options = {
      url: 'LDAP://LPD.foo.net'
      baseDN: 'dc=foo,dc=net'
      username: 'conf'
      password: 'room'
    }

    @activedirectory = {}
    @ActiveDirectory = sinon.spy => @activedirectory
    @sut = new Connector {@ActiveDirectory}
    @sut.start {options}, done

  afterEach (done) ->
    @sut.close done

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->onConfig', ->
    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig { type: 'hello' }).to.not.throw(Error)

  describe '->getUserByUsername', ->
    describe 'when called without a username', ->
      beforeEach (done) ->
        @sut.getUserByUsername undefined, (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist
        expect(=> throw @error).to.throw('Missing required parameter: username')

    describe 'when called with a username', ->
      beforeEach (done) ->
        @activedirectory.findUser = sinon.stub().withArgs('royz').yields null, {
          mail: 'Roy.vandeWater@citrix.com',
          employeeID: 'royv',
          displayName: 'Roy van de Water'
        }

        @sut.getUserByUsername 'royz', (@error, @user) => done(@error)

      it 'instantiate an active directory instance with the credentials', ->
        expect(@ActiveDirectory).to.have.been.calledWithNew
        expect(@ActiveDirectory).to.have.been.calledWith {
          url: 'LDAP://LPD.foo.net'
          baseDN: 'dc=foo,dc=net'
          username: 'conf'
          password: 'room'
        }

      it 'should not yield an error', ->
        expect(@error).not.to.exist

      it 'should yield a user', ->
        expect(@user).to.deep.equal {
          username: 'royv'
          email: 'Roy.vandeWater@citrix.com'
          displayName: 'Roy van de Water'
        }

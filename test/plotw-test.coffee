config = require 'config'
process.env.PLOTW_CLIENT_ID = config.get 'auth.client_id'
process.env.PLOTW_CLIENT_SECRET = config.get 'auth.client_secret'
process.env.PLOTW_REFRESH_TOKEN = config.get 'auth.refresh_token'
process.env.PLOTW_CHANNELS = config.get 'permissions.channels'
process.env.PLOTW_ADMINS = config.get 'permissions.admins'
process.env.PLOTW_USER_ID = config.get 'permissions.user_id'
process.env.PLOTW_SONG_LIMIT = config.get 'permissions.song_limit'

Helper = require 'hubot-test-helper'
helper = new Helper '../src/plotw.coffee'
PlotwManager = require '../src/plotw-manager'

co = require 'co'
expect = require('chai').expect

robot = {}

describe 'PlotwManager', ->
  before -> 
    robot = 
      logger:
        debug: ->
        error: ->
      brain:
        data:
          plotw:
            nominations: []
            history: []
        on: ->
        emit: ->
    @plotw = new PlotwManager robot
    @plotw.storage = @plotw.robot.brain.data.plotw
    @plotw.storage.history = [{id: config.get('test.playlist_id'), link: 'who.cares', date: '1/1/1970'}]

  describe 'add song', ->
    beforeEach ->
      @plotw.robot.brain.data.plotw.nominations = []
      @user = 'test'
      @valid_track_id = '0nq6sfr8z1R5KJ4XUk396e'
      @invalid_track_id = 'a'
      @valid_message = 'Added track.'
      @invalid_message_link = 'Error: Invalid link.'
      @invalid_message_dupe = 'Error: Duplicate user.'

    it 'succeeds on good URI', ->
      @plotw.add_song @user, 'spotify:track:' + @valid_track_id, (err, success) =>
        expect(success.status).to.equal '200'
        expect(success.msg).to.equal @valid_message
        expect(err).to.equal null

    it 'succeeds on good link (open)', ->
      @plotw.add_song @user, 'https://open.spotify.com/track/' + @valid_track_id, (err, success) =>
        expect(success.status).to.equal '200'
        expect(success.msg).to.equal @valid_message
        expect(err).to.equal null

    it 'succeeds on good link (play)', ->
      @plotw.add_song @user, 'https://play.spotify.com/track/' + @valid_track_id, (err, success) =>
        expect(success.status).to.equal '200'
        expect(success.msg).to.equal @valid_message
        expect(err).to.equal null
    
    it 'fails on bad link [random string]', ->
      @plotw.add_song @user, 'trash', (err, success) =>
        expect(success).to.equal null
        expect(err.msg).to.equal @invalid_message_link
        expect(err.status).to.be.undefined

    it 'fails on bad link [random link]', ->
      @plotw.add_song @user, 'https://open.spotify.org/tracks/23rqfdas3fasdf4t', (err, success) =>
        expect(success).to.equal null
        expect(err.msg).to.equal @invalid_message_link
        expect(err.status).to.be.undefined

    it 'fails on bad link [bad URI]', ->
      @plotw.add_song @user, 'spotify:track:' + @invalid_track_id, (err, success) =>
        expect(success).to.equal null
        expect(err.msg).to.equal @invalid_message_link
        expect(err.status).to.equal 'Error adding track: Invalid track uri: spotify:track:' + @invalid_track_id

    it 'fails on bad link [bad link]', ->
      @plotw.add_song @user, 'https://open.spotify.com/track/' + @invalid_track_id, (err, success) =>
        expect(success).to.equal null
        expect(err.msg).to.equal @invalid_message_link
        expect(err.status).to.equal 'Error adding track: Invalid track uri: https://open.spotify.com/track/' + @invalid_track_id

  describe.skip 'add duplicate', ->
    beforeEach ->
      @dupe_user = 'test'
      @valid_track_id = '0nq6sfr8z1R5KJ4XUk396e'
      @plotw.robot.brain.data.plotw.nominations.push({user: @dupe_user, song_id: @valid_track_id})
      co => 
        yield @room.user.say @dupe_user, 'plotw add ' + 'https://play.spotify.com/track/' + @valid_track_id

    it 'fails on duplicate add', ->
      expect(@room.messages).to.deep.equal [
        [@dupe_user, 'plotw add ' + 'https://play.spotify.com/track/' + @valid_track_id]
        ['hubot', 'Error: Duplicate user.']
      ]
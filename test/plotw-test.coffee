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
    @plotw.storage.history = [{id: process.env.PLOTW_TEST_PLAYLIST, link: 'who.cares', date: '1/1/1970'}]

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

    describe 'add duplicate', ->
      beforeEach ->
        @room = helper.createRoom()
        @dupe_user = 'test'
        @valid_track_id = '0nq6sfr8z1R5KJ4XUk396e'
        @plotw.storage.history = [{id: process.env.PLOTW_TEST_PLAYLIST, link: 'who.cares', date: '1/1/1970'}]
        @plotw.storage.nominations.push({user: @dupe_user, song_id: @valid_track_id})

      it 'fails on duplicate add', ->
        @plotw.add_song @dupe_user, 'https://play.spotify.com/track/' + @valid_track_id, (err, success) =>
          expect(success).to.equal null
          expect(err.msg).to.equal 'Error: Duplicate user.'

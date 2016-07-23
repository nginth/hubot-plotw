request = require 'request'
auth = require './auth'

class PlotwManager
    constructor: (@robot) ->
        @robot.brain.on 'loaded', =>
            @storage = @robot.brain.data.plotw ?= {
                nominations: []
                history: []
            }
        @set_environment()

    is_admin: (user) ->
        return user in @admins

    is_valid_channel: (channel) ->
        return channel in @channels

    get_playlists: (callback) ->
        auth.with_auth (access_token) ->
            get_options = {
                url: 'https://api.spotify.com/v1/users/'+@user_id+'/playlists',
                headers: {'Authorization': 'Bearer ' + access_token},
                json: true
            }
            request.get get_options, (err, res, body) ->
                if body.error
                    @robot.logger.error body.error
                    callback('Error getting playlists: ' + body.error.message, null)
                    return
                callback(null, body)

    is_dupe_user: (user) ->
        exists = @storage.nominations.filter (nom) =>
            return nom.user == user
        return exists.length >= @song_limit

    is_dupe_song: (song_id) ->
        exists = @storage.nominations.filter (nom) =>
            return nom.song_id == song_id
        return exists.length

    add_song: (user, song_uri, callback) -> 
        if not @storage.history.length
            callback {msg: 'Error: No current playlist. Please run \"plotw new\".'}, null
            return
        if @is_dupe_user user
            callback {msg: 'Error: Duplicate user.'}, null
            return
        spotify_uri = /^(spotify:track:)[a-zA-z0-9]*$/
        spotify_link = /^(http)s?(:\/\/(open|play).spotify.com\/track\/)[a-zA-z0-9]*$/
        song_id = ''
        if spotify_uri.test(song_uri)
            @robot.logger.debug 'Adding Spotify URI: ' + song_uri
            song_id = song_uri.split(':')[2].trim()
        else if spotify_link.test(song_uri)
            song_id = song_uri.split('/')[4].trim()
            song_uri = 'spotify:track:' + song_id
            @robot.logger.debug 'Adding Spotify Link: ' + song_uri
        else
            callback({msg: 'Error: Invalid link.'}, null)
            return

        if @is_dupe_song song_id
            callback {msg: 'Error: Duplicate song.'}, null
            return         

        auth.with_auth (access_token) =>
            playlist_id = @storage.history[@storage.history.length - 1].id
            post_options = {
                url: 'https://api.spotify.com/v1/users/'+@user_id+'/playlists/'+playlist_id+'/tracks'
                headers: {'Authorization': 'Bearer ' + access_token}
                qs: {uris: song_uri}
                json: true
            }
            request.post post_options, (err, res, body) =>
                if body.error
                    @robot.logger.error body.error
                    callback({status: res.statusCode, msg: 'Error adding track: ' + body.error.message}, null)                    
                    return
                @storage.nominations.push({user: user, song_id: song_id})
                @save
                callback null, {status: res.statusCode, msg: 'Added track.'}

    new_playlist: (user, callback) ->
        if not @is_admin user
            callback null, {msg: 'Invalid permissions.'}
            return

        num = @storage.history.length
        auth.with_auth (access_token) =>
            pl_date = @get_date()
            post_options = {
                url: 'https://api.spotify.com/v1/users/'+@user_id+'/playlists'
                headers: {'Authorization': 'Bearer ' + access_token, 'Content-Type': 'application/json'}
                body: { name: 'Playlist of the Week ' + num + ' (' + pl_date + ')' }
                json: true
            }
            request.post post_options, (err, res, body) =>
                if body.error
                    @robot.logger.error body.error
                    callback({status: res.statusCode, msg: 'Error creating playlist: ' + body.error.message}, null)
                    return
                @storage.nominations = []
                @storage.history.push({id: body.id, link: body.external_urls.spotify, date: pl_date})
                @robot.logger.debug 'Added to history: ' + @storage.history[@storage.history.length - 1].id
                @save
                callback null, {status: res.statusCode, msg: 'New playlist created.'}

    get_nominations: ->
        return @storage.nominations

    get_history: ->
        return @storage.history

    reset: (user) ->
        if not @is_admin user
            return 'Insufficient permissions.'
        @robot.brain.data.plotw = {nominations: [], history: []}
        @save
        return 'Reset plotw.'

    save: ->
        @robot.brain.emit 'save'

    get_date: ->
        today = new Date
        month = today.getMonth() + 1
        day = today.getDate()
        year = today.getFullYear()
        if day < 10
            day = '0' + day
        if month < 10
            month = '0' + month
        return month + '/' + day + '/' + year

    set_environment: ->
        @channels = ['Shell']
        @admins = ['Shell']
        @user_id = 'notarealuser'
        @song_limit = 1
        if (process.env.PLOTW_CHANNELS not undefined)
            @channels = process.env.PLOTW_CHANNELS.split(',')
        if (process.env.PLOTW_ADMINS not undefined)
            @admins = process.env.PLOTW_ADMINS.split(',')
        if (process.env.PLOTW_USER_ID not undefined)
            @user_id = process.env.PLOTW_USER_ID
        if (process.env.PLOTW_SONG_LIMIT not undefined)
            @song_limit = process.env.PLOTW_SONG_LIMIT

module.exports = PlotwManager
request = require 'request'

client_id = process.env.PLOTW_CLIENT_ID
client_secret = process.env.PLOTW_CLIENT_SECRET
refresh_token = process.env.PLOTW_REFRESH_TOKEN
exports.with_auth = (callback) ->
    data = JSON.stringify
        grant_type: 'refresh_token'
        refresh_token: refresh_token
    authOptions = 
        url: 'https://accounts.spotify.com/api/token'
        headers: { 'Authorization': 'Basic ' + (new Buffer(client_id + ':' + client_secret).toString('base64')) }
        form: 
          grant_type: 'refresh_token'
          refresh_token: refresh_token
        json: true

    request.post authOptions, (err, res, body) ->
        if err
            console.log err
            return null
        callback(body.access_token)

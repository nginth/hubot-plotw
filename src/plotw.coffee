# Description:
#   Collaborative playlist creation.
#
# Dependencies:
#
# Configuration:
#
# Commands:
#   plotw add <spotify track URI> - adds song to current playlist
#
# Author:
#   nginth
#
PlotwManager = require './plotw-manager'

module.exports = (robot) ->
    plotw = new PlotwManager robot

    help = 'HELP: \ncommands: add <'  

    robot.hear /help/i, (msg) ->
        msg.send help

    robot.hear /add (.*)/i, (msg) ->
        song_id = msg.match[1]
        robot.logger.debug 'Adding to playlist: ' + song_id 
        plotw.add_song msg.message.user.name, song_id, (err, success) ->
            if err
                msg.send err.msg
                return
            msg.send success.msg

    robot.hear /new/i, (msg) ->
        plotw.new_playlist msg.message.user.name, (err, success) ->
            if err
                msg.send err.msg
                return
            msg.send success.msg

    robot.hear /nominations/i, (msg) ->
        nominations = plotw.get_nominations()
        if not nominations.length
            msg.send 'No current nominations.'
            return
        i = 0
        for nom in nominations
            msg.send ++i + '. ' + nom.user.slice(0,1) + '.' + nom.user.slice(1) + ' https://open.spotify.com/track/' + nom.song_id

    robot.hear /history/i, (msg) ->
        history = plotw.get_history()
        if not history.length
            msg.send 'No history.'
            return
        i = 0
        for playlist in history
            msg.send ++i + '. (' + playlist.date + ') ' + playlist.link

    robot.hear /current/i, (msg) ->
        history = plotw.get_history()
        if not history.length
            msg.send 'No current playlist.'
            return
        playlist = history[history.length - 1]
        msg.send 'Current playlist (' + playlist.date + '): ' + playlist.link

    robot.hear /reset/i, (msg) ->
        msg.send plotw.reset msg.message.user.name

# Description:
#   Collaborative playlist creation.
#
# Dependencies:
#
# Configuration:
#
# Commands:
#   see usage
#
# Author:
#   nginth
#
PlotwManager = require './plotw-manager'

module.exports = (robot) ->
    plotw = new PlotwManager robot

    usage = """
            plotw commands:
            `plotw add <spotify URI>`   - add a song to the current playlist
            `plotw nominations`         - print the current nominations
            `plotw history`             - print links to the past playlists
            `plotw current`             - print a link to the current playlist
            `plotw new`                 - clear nominations and create a new playlist
            `plotw reset`               - clear nominations and history (start anew)
            """

    plotw_add = (msg, song_id) ->
        robot.logger.debug 'Adding to playlist: ' + song_id 
        plotw.add_song msg.message.user.name, song_id, (err, success) ->
            if err
                msg.send err.msg
                return
            msg.send success.msg

    plotw_new = (msg) ->
        plotw.new_playlist msg.message.user.name, (err, success) ->
            if err
                msg.send err.msg
                return
            msg.send success.msg

    plotw_nominations = (msg) ->
        nominations = plotw.get_nominations()
        if not nominations.length
            msg.send 'No current nominations.'
            return
        i = 0
        for nom in nominations
            msg.send ++i + '. ' + nom.user.slice(0,1) + '.' + nom.user.slice(1) + ' https://open.spotify.com/track/' + nom.song_id

    plotw_history = (msg) ->
        history = plotw.get_history()
        if not history.length
            msg.send 'No history.'
            return
        i = 0
        for playlist in history
            msg.send ++i + '. (' + playlist.date + ') ' + playlist.link

    plotw_current = (msg) ->
        history = plotw.get_history()
        if not history.length
            msg.send 'No current playlist.'
            return
        playlist = history[history.length - 1]
        msg.send 'Current playlist (' + playlist.date + '): ' + playlist.link

    plotw_reset = (msg) ->
        msg.send plotw.reset msg.message.user.name

    robot.hear /^(plotw)(\s)(.*)/, (msg) =>
        cmd = msg.match[3].split(' ') 
        switch cmd[0]
            when 'help' then msg.send usage
            when 'add' then plotw_add msg, cmd[1]
            when 'new' then plotw_new msg
            when 'nominations' then plotw_nominations msg
            when 'history' then plotw_history msg
            when 'current' then plotw_current msg
            when 'reset' then plotw_reset msg
            else msg.send usage
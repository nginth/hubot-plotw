# hubot-plotw

[![Build Status](https://travis-ci.org/nginth/hubot-plotw.svg?branch=master)](https://travis-ci.org/nginth/hubot-plotw)

Collaborative spotify playlists.

See [`src/plotw.coffee`](src/plotw.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-plotw --save`

Then add **hubot-plotw** to your `external-scripts.json`:

```json
[
  "hubot-plotw"
]
```

## Configuration

**hubot-plotw** uses 7 environment variables for configuration. These are as follows:

#### Permissions
`PLOTW_CHANNELS` - comma separated list of channels this package can be used in

`PLOTW_ADMINS` - comma separated list of users that can use restricted commands (new, reset)

`PLOTW_SONG_LIMIT` - amount of songs a single user can nominate per playlist

#### Spotify

All these need to be obtained and set before **hubot-plotw** will work. If you do not already have this information, I suggest going through the Spotify [Web API Tutorial](https://developer.spotify.com/web-api/tutorial/) and pulling the information from there.

`PLOTW_USER_ID` - id of the spotify user that playlists will be created for

`PLOTW_CLIENT_ID` - the unique application identifier provided by Spotify

`PLOTW_CLIENT_SECRET` - the secret key provided by Spotify

`PLOTW_REFRESH_TOKEN` - the refresh token provided by the Spotify user auth flow

#### Example
```
PLOTW_CHANNELS="music,bot-testing"
PLOTW_ADMINS="Admin,Nick"
PLOTW_SONG_LIMIT=1
PLOTW_USER_ID="myspotifyid"
PLOTW_CLIENT_ID="<some_long_string>"
PLOTW_CLIENT_SECRET="<some_long_string>"
PLOTW_REFRESH_TOKEN="<some_long_string>"
```

## Commands

`plotw help`                - print usage

`plotw add <spotify URI>`   - add a song to the current playlist

`plotw nominations`         - print the current nominations

`plotw history`             - print links to the past playlists

`plotw current`             - print a link to the current playlist

`plotw new`                 - clear nominations and create a new playlist

`plotw reset`               - clear nominations and history (start anew)


## NPM Module

https://www.npmjs.com/package/hubot-plotw

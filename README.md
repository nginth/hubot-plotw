# hubot-plotw

[![Build Status](https://travis-ci.org/nginth/hubot-plotw.svg?branch=master)](https://travis-ci.org/nginth/hubot-plotw)

Collaborative spotify playlists.

See [`src/plotw.coffee`](src/plotw.coffee) for full documentation.

Warning: none of the below is ready yet. You could install this by manually copying it to your scripts folder though.

## Installation

In hubot project repo, run:

`npm install hubot-plotw --save`

Then add **hubot-plotw** to your `external-scripts.json`:

```json
[
  "hubot-plotw"
]
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

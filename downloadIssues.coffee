request = require 'request'
fs = require 'fs'
es6shim = require 'es6-shim'

options = {
  url: 'https://api.github.com/repos/adobe/brackets/issues?milestone=26', # Milestone 1.0
  headers: { 'User-Agent': 'request' }
}

linkRegex = /<(.*?)>;\s+?rel="(.*?)",\s+?<(.*?)>;\s*?rel="(.*?)"/

nextUrl = (link) ->
  parts = link.split linkRegex
  url

  url = parts[1] if parts[2] is "next"
  url = parts[3] if parts[4] is "next"

  url

download = (options) ->
  issues = []
  new Promise( (resolve) ->
    _download = (opts) ->
      request opts, (error, response, body) ->
        url = nextUrl response.headers.link

        issues = issues.concat JSON.parse(body)
        if url
          options.url = url
          _download options
        else
          resolve(issues)

    _download options
  )

p = download options
p.then (content) ->
#  fs.writeFileSync 'Brackets-1.0-Milestone-issues.json', JSON.stringify content
  console.log JSON.stringify content

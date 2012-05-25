fs = require 'fs'

WootRef = require './ref'


module.exports = class WootFileTemplate

  constructor: (@relPath, @absPath) ->

  scan: (params, callback) ->
    WootRef.process @relPath, params

    await fs.readFile @absPath, 'utf-8', defer(err, content)
    return callback(err) if err

    WootRef.process content, params

    callback()

  apply: (builder, values, callback) ->
    destPath = WootRef.process @relPath, null, values

    await fs.readFile @absPath, 'utf-8', defer(err, content)
    return callback(err) if err

    content = WootRef.process content, null, values

    builder.addFile destPath, content, callback

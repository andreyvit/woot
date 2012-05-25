Path = require 'path'
fs   = require 'fs'
mkdirp = require 'mkdirp'

{ EventEmitter } = require 'events'
{ exec } = require 'child_process'


module.exports = class WootBuilder extends EventEmitter

  constructor: (@root) ->

  addFile: (relPath, content, autocb) ->
    absPath = Path.join(@root, relPath)

    await Path.exists absPath, defer(exists)
    if exists
      @emit 'exists', relPath
      return

    await mkdirp Path.dirname(absPath), defer(err)
    if err
      @emit 'error', err, relPath
      return

    await fs.writeFile absPath, content, defer(err)
    if err
      @emit 'error', err, relPath
      return

    @emit 'file', relPath

  execute: (command, autocb) ->
    @emit 'execute', command
    await exec command, { cwd: @root }, defer(err, stdout, stderr)

    if err
      @emit 'error', err
      return

    @emit 'output', (stdout.trim() + "\n" + stderr.trim()).trim()

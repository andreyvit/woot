Path = require 'path'
fs   = require 'fs'

{ TreeStream, RelPathList } = require 'pathspec'

WootFileTemplate = require './file'
WootRef = require './ref'
Formats = require './formats'


class WootParam

  constructor: (@name) ->
    @refs = []

  in: (format) ->
    Formats[format].build(@name)

  formats: ->
    result = {}
    for ref in @refs
      result[ref.format] = yes
    return (name for own name, _ of Formats when result[name])



module.exports = class WootTemplate

  constructor: (@folder) ->
    @files = []

    @namesToParams = {}
    @params = []


  lookupParam: (name, create=no) ->
    if @namesToParams.hasOwnProperty(name)
      param = @namesToParams[name]
    else if create
      param = @namesToParams[name] = new WootParam(name)
      @params.push param
      param
    else
      null


  scan: (callback) ->
    stream = new TreeStream(RelPathList.parse(['*', '!woot.json', '!.DS_Store'])).visit(@folder)


    wootFile = Path.join(@folder, 'woot.json')
    @wootOptions = {}
    if Path.existsSync(wootFile)
      @wootOptions = JSON.parse(fs.readFileSync(wootFile, 'utf-8'))


    refs = []
    await
      stream.on 'file', (relPath, absPath) =>
        wfile = new WootFileTemplate(relPath, absPath)
        @files.push wfile
        wfile.scan refs, defer()

      stream.on 'end', defer()

    for command in @wootOptions.after || []
      WootRef.process command, refs


    for ref in refs
      @lookupParam(ref.name, yes).refs.push ref


    callback()


  apply: (builder, values, callback) ->
    await
      for file in @files
        file.apply builder, values, defer()

    for command in @wootOptions.after || []
      command = WootRef.process(command, null, values)
      await builder.execute command, defer()

    callback()

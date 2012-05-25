Formats = require './formats'


module.exports = class WootRef

  constructor: (@name, @format, @src) ->

  format: (value) ->
    value.in(@format)

  @process = (string, params=null, values=null) ->
    string = string.replace ///__ ([a-zA-Z0-9_-]+? (?: \swoot)? ) __///g, (src, name) ->
      { name, format } = Formats.parse(name)
      if params
        params.push new WootRef(name, format, src)
      if values
        if values.hasOwnProperty(name)
          return Formats[format].build(values[name])
        else
          throw new Error "Undefined reference to var '#{name}' (src ref: '#{src}')"
      else
        return src

    return string

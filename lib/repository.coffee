Path = require 'path'

WootTemplate = require './template'

module.exports = class WootRepository

  constructor: ->
    @folder = Path.join(process.env['HOME'], '.woot')

  find: (templateName) ->
    subfolder = Path.join(@folder, templateName)
    if Path.existsSync(subfolder)
      new WootTemplate(subfolder)
    else
      null

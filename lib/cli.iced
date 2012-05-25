Path     = require 'path'
fs       = require 'fs'
debug    = require('debug')('woot:cli')
readline = require 'readline'
dreamopt = require 'dreamopt'

WootRepository = require './repository'
WootBuilder = require './builder'
Formats = require './formats'


module.exports = (args) ->
  userSettingsFile = Path.join(process.env.HOME, '.woot.json')
  userSettings = {}
  if Path.existsSync(userSettingsFile)
    userSettings = JSON.parse(fs.readFileSync(userSettingsFile, 'utf-8'))

  # option processing stage 1: find repository and template (if applicable) to get the final option list

  bogusOptions = []

  options = dreamopt [
    "  template"
    "  dir"
    "  -y, --dont-ask"
    "  --save"
    "  --help  Disable built-in --help handler by providing a dummy option #bool"
  ], {
     # allow any long options at this stage
    resolveLongOption: (name, options, syntax) ->
      bogusOptions.push name
      syntax.add "  --#{name} VALUE"
  }, args


  # process --save here and now; can't run stage 2 because we allow saving arbitrary options
  if options.save
    for name in bogusOptions
      userSettings[name] = options[name]
    fs.writeFileSync userSettingsFile, JSON.stringify(userSettings, null, 2)
    process.stderr.write "#{userSettingsFile} updated.\n"
    process.exit 0


  # lookup the chosen template and add its options to our list
  repository = new WootRepository()

  syntax = [
    "Usage: woot subdir #{options.template || 'template'} [--option VALUE]..."

    "Arguments:"
    "  template  Template name to apply"
    "  subdir  A folder to operate in; will be created if necessary; defaults to '.' #default(.)", (path) ->
      return Path.resolve(path)

    "Operation modes:"
    "  --save  Save the given options in ~/.woot.json to be reused later"

    "Template generation options:"
    "  -y, --dont-ask  Don't ask to confirm the argument values #var(dont_ask)"
  ]

  if options.template
    template = repository.find(options.template)
    unless template
      process.stderr.write "Template not found: #{options.template}\n"
      process.exit 1

    await template.scan defer()

    syntax.push "Template arguments:"
    for param in template.params
      syntax.push "  --#{param.in('dashed')} VALUE  #var(#{param.name})"

  syntax.push "Other options:"


  # option processing stage 2: this time for real
  options = dreamopt(syntax, args)

  debug "Options: " + JSON.stringify(options)

  unless Path.existsSync(Path.dirname(options.subdir))
    process.stderr.write "Parent folder of the target subfolder must exist: #{Path.dirname(options.subdir)}\n"
    process.exit 1

  values = { name: Path.basename(options.subdir) }
  missing = []
  for param in template.params
    if options.hasOwnProperty(param.name)
      values[param.name] = options[param.name]  # override even if already defined
    else if values.hasOwnProperty(param.name)
      # keep the predefined value
    else if userSettings.hasOwnProperty(param.in('dashed'))
      values[param.name] = userSettings[param.in('dashed')]
    else
      missing.push param

  ri = readline.createInterface(process.stdin, process.stdout, null)
  ri.on 'close', ->
    process.stderr.write '\n'
    process.exit 0

  if missing.length > 0
    process.stderr.write "\nYou will now be prompted for the following values:\n\n"
    for param in missing
      process.stderr.write "  --#{param.in('dashed')} VALUE\n"

    process.stderr.write "\nYou can also provide them on the command line if you want.\n"

    for param in missing
      await ri.question "#{param.name}: ", defer(answer)
      values[param.name] = answer.trim()

  process.stderr.write "\nArgument values:\n"
  for param in template.params
    raw = values[param.name]
    for format in param.formats()
      process.stderr.write "  #{param.name} (#{format}) = #{Formats[format].build(raw)}\n"
  process.stderr.write "\n"

  unless options.dont_ask
    loop
      await ri.question "Is this correct (yes/no) [yes]: ", defer(answer)
      break if answer in ['', 'y', 'yes', 'n', 'no']
    unless answer in ['', 'y', 'yes']
      process.stderr.write "Cancelled.\n"
      process.exit 1

  process.stderr.write "\n"

  builder = new WootBuilder(options.subdir)
  builder.on 'exists', (path) ->
    process.stderr.write " existing  #{path}\n"
  builder.on 'file', (path) ->
    process.stderr.write " add       #{path}\n"
  builder.on 'execute', (command) ->
    process.stderr.write " run       #{command}\n"
  # builder.on 'output', (output) ->
  #   process.stderr.write output + "\n"

  unless Path.existsSync(options.subdir)
    process.stderr.write " create    #{options.subdir}\n"
    fs.mkdirSync(options.subdir)

  await template.apply builder, values, defer()

  process.stderr.write "\nFinished.\n"

  ri.close()
  process.stdin.destroy()

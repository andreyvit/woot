
camelCaseToUnderscores = (camelCase) -> camelCase.replace(/([a-z0-9])([A-Z])/g, '$1_$2').replace(/[- ]/g, '_').toLowerCase()

Formats =
  'raw':
    build: (raw) -> raw

  'underscored':
    build: (raw) -> camelCaseToUnderscores(raw)

  'dashed':
    build: (raw) -> camelCaseToUnderscores(raw).replace(/_/g, '-')

  'camelCase':
    build: (raw) -> camelCaseToUnderscores(raw).replace(/_([a-z])/g, (_, x) -> x.toUpperCase())

  'CamelCase':
    build: (raw) -> camelCaseToUnderscores(raw).replace(/(?:^|_)([a-z])/g, (_, x) -> x.toUpperCase())

  'human readable':
    build: (raw) ->
      if raw.indexOf(' ') >= 0
        raw
      else
        camelCaseToUnderscores(raw).replace(/_/g, ' ').trim()

  'Human Readable Title':
    build: (raw) ->
      if raw.indexOf(' ') >= 0
        raw
      else
        camelCaseToUnderscores(raw).replace(/_/g, ' ').replace(/(^| )([a-z])/g, (_, p, x) -> p + x.toUpperCase()).trim()

  parse: (name) ->
    if name.match /_raw$/
      format = 'raw'
      name = name.replace /_raw$/, ''

    else if name.indexOf(' ') >= 0
      if name.search(/[A-Z]/) >= 0
        format = 'Human Readable Title'
      else
        format = 'human readable'
      name = name.replace(/[ ]/g, '_').toLowerCase()

    else if name.search(/[A-Z]/) >= 0 && name.indexOf('_') < 0
      if name.search(/^[A-Z]/) >= 0
        format = 'CamelCase'
      else
        format = 'camelCase'
      name = name.replace(/([a-z0-9])([A-Z])/g, '$1_$2').toLowerCase()

    else if name.indexOf('_') >= 0 && name.search(/[A-Z]/) < 0
      format = 'underscored'
      name = name

    else if name.indexOf('-') >= 0 && name.search(/[A-Z]/) < 0
      format = 'dashed'
      name = name

    else
      format = 'underscored'
      name = name

    name = name.replace /[_ -]woot$/, ''

    return { name, format }

module.exports = Formats

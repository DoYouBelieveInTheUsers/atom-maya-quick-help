# coffeelint: disable=max_line_length
$ = require 'jquery'
QuickHelpView = require './atom-maya-quick-help-view'
{CompositeDisposable} = require 'atom'

module.exports =
  QuickHelpView: null
  subscriptions: null

  config:
    language:
      title: 'Language (Mel or Python)'
      description: 'Default is Python'
      type: 'string'
      default: 'Python'
      enum: ['Python', 'Mel']
    mayaVersion:
      title: 'Maya version'
      description: 'Select version of Maya you are developing for. (Default is 2018)'
      type: 'string'
      default: '2018'
      enum: ["2018", "2017", "2016", "2015"]

  activate: (state) ->

    @subscriptions = new CompositeDisposable()
    options = atom.config.getAll('atom-maya-quick-help')[0].value
    @QuickHelpView = new QuickHelpView(options)

    @subscriptions.add atom.config.onDidChange 'atom-maya-quick-help', (event) =>
      settings = event.newValue
      for key, value in settings
        if key.indexOf('Groups') > 0
          settings[key] = value.split(',')
      @QuickHelpView.updateOptions(settings)

    @subscriptions.add atom.commands.add 'atom-workspace'
      , 'nav-panel:toggle': => @toggle()
    #Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'atom-maya-quick-help:toggle': () => @toggle()
    }))
    #Register command that gets the command arguments
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'atom-maya-quick-help:getCommand': () => @QuickHelpView.getFlags()
    }))

  deactivate: () ->
    this.subscriptions.dispose()
    this.QuickHelpView.destroy()

  serialize: () ->
    return {
      QuickHelpViewState: this.QuickHelpView.serialize()
    }

  toggle: ->
    @QuickHelpView.enable()

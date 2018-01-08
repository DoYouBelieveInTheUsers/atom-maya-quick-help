# coffeelint: disable=max_line_length
'use babel'
$ = require 'jquery'
fs = require 'fs'
os = require 'os'
selectListView = require 'atom-select-list'
SidePanel = require './atom-maya-quick-help-side-panel'
exec = require('child_process').exec
shell = require('electron').shell
pyshell = require('python-shell')
path = require 'path'
module.exports =

class QuickHelpView extends SidePanel
  panel: null
  options: {}
  selectListView: null
  commandList: []
  editor: null
  version: null
  lang: null
  body:  null

  constructor: (options)->
    super()
    @options = options

    @version = @options.mayaVersion

    if @options.language == "Mel"
      @language = ""
    else
      @language = options.language

    @panel = atom.workspace.addRightPanel(
      item: @viewContainer
      visible: false
      priority: 300
    )
    #Get a reference to the editor. So we can grab selected text
    @editor = atom.workspace.getActiveTextEditor()

    @btn = $(@viewContainer).find('.btn')
    @btn.on 'click', (e) => @goToCommandDocs()

    @setCommandList()
    @createSelectList()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @panel.remove()
    @selectListView.element.remove()

  updateOptions: (options) ->
    @options = options
    if @options.language == "Mel"
      @language = ""
    else
      @language = @options.language
    if @version != @options.mayaVersion
      @version = @options.mayaVersion
    @updateSelectList()

  getElement: ->
    @element

  enable: ->
    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()

  setCommandList: () ->
    file = os.homedir() + "\\.atom\\packages\\atom-maya-quick-help\\source\\Commands_" + @language + "_" + @version + ".txt"
    #console.log file
    if fs.existsSync(file)
      readCmdListFile = ->
        fs.readFileSync file, 'utf-8'
      @commandList = readCmdListFile().split("\n")
    else
      console.log("Not Exist")  #TODO generate cmds list if missing

  createSelectList: () ->
    @selectListView = new selectListView({
      items: @commandList,
      elementForItem: (item) =>
        li = document.createElement('li')
        li.textContent = item
        @searchbox.appendChild(li)
        return li
      didConfirmSelection: (item) =>
        @selectListView.refs.queryEditor.setText(item)
        @getFlags(item)
    })
    @searchbox.appendChild(@selectListView.element)

  updateSelectList: ->
    #Empty the current selectListView item array then reset it based new options
    @setCommandList()
    @selectListView.items = @commandList
    @selectListView.update()

  getFlags: (command) ->
    if !command
      command = @editor.getSelectedText()
    if command
      cmd = "python \"#{__dirname}/get-maya-args.py\""
      cmd += " -c \"#{command}\""
      cmd += " -v \"#{@version}\""
      cmd += " -l \"#{@language}\""
      #console.log cmd
      exec cmd, (error, stdout, stderr) =>
        if error?
          console.error 'error', error
        else
          @createTableRows(stdout)
          @selectListView.refs.queryEditor.setText(command)
    else
      console.log("cmds list not found")

  createTableRows: (argstring) ->
    @clear()
    args = argstring.split('\n')
    for arg, index in args
      if arg != "" | "\n" #catch the empty arg caused by split
        if index %% 3 == 0
          row = document.createElement('tr')
        content = document.createElement('td')
        content.textContent = arg
        if index %% 3 == 2
        else
          content.classList.add('cellhover')
        row.appendChild(content)
        @body.appendChild(row)
    @addCellEvents()

  addCellEvents: () ->
    sendCmd = (cmd) =>
      @insertCmd(cmd)
    $('td').each ->
      if $(this).hasClass('cellhover')
        $(this).on 'dblclick', (e) -> sendCmd($(this).text())
  insertCmd: (cmd)->
    cmdstring = cmd.replace(/^\s+|\s+$|\n/g, '')
    @editor.insertText(cmdstring)

  clear: ->
    if $(@body).children().length > 0
      $(@body).empty()

  goToCommandDocs: () ->
    selectListCmd = @selectListView.refs.queryEditor.getText().trim()
    if !selectListCmd
      selectListCmd = @editor.getSelectedText()
    if selectListCmd
      addr = "http://help.autodesk.com/cloudhelp/" +
      @version + "/ENU/Maya-Tech-Docs/Commands" + @language +
      "/" + selectListCmd + ".html"
      console.log @language
      console.log addr
      shell.openExternal(addr)
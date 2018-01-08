$ = require 'jquery'
{Disposable} = require 'atom'
module.exports =

class SideView
  commandList: null
  viewContainer: null
  header: null
  mainView: null
  handle: null
  resizerPos: null
  searchbox: null

  constructor: (resizerPos = 'left')->
    @resizerPos = resizerPos
    #MView Container
    @viewContainer = document.createElement('div')
    @viewContainer.classList.add('atom-maya-quick-help')

    #MainView
    @mainView = document.createElement('div')
    @mainView.classList.add('atom-maya-quick-help-mainview')
    @viewContainer.appendChild(@mainView)

    # Header
    @header = document.createElement('div')
    @header.classList.add('atom-maya-quick-help-header')
    h2 = document.createElement('h2')
    h2.textContent = "Maya Quick Help"
    @searchbox = document.createElement('div')
    #@searchbox.setAttribute('mini', true)
    @searchbox.classList.add('searchbox')
    @header.appendChild(h2)
    @header.appendChild(@searchbox)
    handle = document.createElement('div')
    handle.classList.add('atom-maya-quick-help-height-resizer')
    @header.appendChild(handle)
    @viewContainer.appendChild(@header)

    #Table
    @table = document.createElement('table')
    @table.classList.add('atom-maya-quick-help-table')
    @table.setAttribute('id', "table1")
    @table.setAttribute('width', "100%")
    @table.setAttribute("id", "argtable")
    lNameRow = document.createElement('th')
    lNameRow.setAttribute('width', '40%')
    lNameRow.textContent = "Long Name"
    sNameRow = document.createElement('th')
    sNameRow.setAttribute('width', '30%')
    sNameRow.textContent = "Short Name"
    aTypeRow = document.createElement('th')
    aTypeRow.setAttribute('width', '30%')
    aTypeRow.textContent = "Arg Type"
    @body = document.createElement('tbody')
    @table.appendChild(lNameRow)
    @table.appendChild(sNameRow)
    @table.appendChild(aTypeRow)
    @table.appendChild(@body)
    @viewContainer.appendChild(@table)
    btnDiv1 = document.createElement('div')
    btnDiv1.classList.add('button-area')
    @btn1 = document.createElement('button')
    @btn1.classList.add('btn')
    @btn1.textContent = "Open Command Documention"
    btnDiv1.appendChild(@btn1)
    @viewContainer.appendChild(btnDiv1)

    @handle = $(@viewContainer).find('.atom-maya-quick-help-height-resizer')
    @handleEvents()

  handleEvents: () ->
    @handle.on  'mousedown', (e) => @resizeStarted(e)

  resizeStarted: =>
    @searchboxList = $(@searchbox).find('ol')
    $(document).on('mousemove', @resizeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeView)
    $(document).off('mouseup', @resizeStopped)

  resizeView: ({pageY, which}) =>
    return @resizeStopped() unless which is 1

    if @searchboxList.length
      height = pageY - @searchboxList.offset().top

    @searchboxList.height(height)
    if height < 200
      $(@searchboxList).css({'maxHeight': height})

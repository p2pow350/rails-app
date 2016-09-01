###
  A simple, lightweight jQuery plugin for creating sortable tables.
  https://github.com/kylefox/jquery-tablesort
  Version 0.0.1
###

(($) ->

  $.tablesort = ($table, settings) ->
    self = this
    @$table = $table
    @settings = $.extend({}, $.tablesort.defaults, settings)
    @$table.find('thead th').bind 'click.tablesort', ->
      if !$(this).hasClass('disabled')
        self.sort $(this)
      return
    @index = null
    @$th = null
    @direction = []
    return

  $.tablesort.prototype =
    sort: (th, direction) ->
      start = new Date
      self = this
      table = @$table
      rows = table.find('tbody tr')
      index = th.index()
      cache = []
      fragment = $('<div/>')

      sortValueForCell = (th, td, sorter) ->
        sortBy = undefined
        if th.data().sortBy
          sortBy = th.data().sortBy
          return if typeof sortBy == 'function' then sortBy(th, td, sorter) else sortBy
        if td.data('sort') then td.data('sort') else td.text()

      naturalSort = (a, b) ->
        `var index`
        chunkRegExp = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?$|^0x[0-9a-f]+$|[0-9]+)/gi
        stripRegExp = /(^[ ]*|[ ]*$)/g
        dateRegExp = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/
        numericRegExp = /^0x[0-9a-f]+$/i
        oRegExp = /^0/
        cLoc = 0

        useInsensitive = (string) ->
          ('' + string).toLowerCase().replace ',', ''

        x = useInsensitive(a).replace(stripRegExp, '') or ''
        y = useInsensitive(b).replace(stripRegExp, '') or ''
        xChunked = x.replace(chunkRegExp, '\u0000$1\u0000').replace(/\0$/, '').replace(/^\0/, '').split('\u0000')
        yChunked = y.replace(chunkRegExp, '\u0000$1\u0000').replace(/\0$/, '').replace(/^\0/, '').split('\u0000')
        chunkLength = Math.max(xChunked.length, yChunked.length)
        xDate = parseInt(x.match(numericRegExp), 10) or xChunked.length != 1 and x.match(dateRegExp) and Date.parse(x)
        yDate = parseInt(y.match(numericRegExp), 10) or xDate and y.match(dateRegExp) and Date.parse(y) or null
        xHexValue = undefined
        yHexValue = undefined
        index = undefined
        # first try and sort Hex codes or Dates
        if yDate
          if xDate < yDate
            return -1
          else if xDate > yDate
            return 1
        # natural sorting through split numeric strings and default strings
        index = 0
        while index < chunkLength
          # find floats not starting with '0', string or 0 if not defined (Clint Priest)
          xHexValue = !(xChunked[index] or '').match(oRegExp) and parseFloat(xChunked[index]) or xChunked[index] or 0
          yHexValue = !(yChunked[index] or '').match(oRegExp) and parseFloat(yChunked[index]) or yChunked[index] or 0
          # handle numeric vs string comparison - number < string - (Kyle Adams)
          if isNaN(xHexValue) != isNaN(yHexValue)
            return if isNaN(xHexValue) then 1 else -1
          else if typeof xHexValue != typeof yHexValue
            xHexValue += ''
            yHexValue += ''
          if xHexValue < yHexValue
            return -1
          if xHexValue > yHexValue
            return 1
          index++
        0

      if rows.length == 0
        return
      self.$table.find('thead th').removeClass self.settings.asc + ' ' + self.settings.desc
      @$th = th
      if @index != index
        @direction[index] = 'desc'
      else if direction != 'asc' and direction != 'desc'
        @direction[index] = if @direction[index] == 'desc' then 'asc' else 'desc'
      else
        @direction[index] = direction
      @index = index
      direction = if @direction[index] == 'asc' then 1 else -1
      self.$table.trigger 'tablesort:start', [ self ]
      self.log 'Sorting by ' + @index + ' ' + @direction[index]
      rows.sort (a, b) ->
        aRow = $(a)
        bRow = $(b)
        aIndex = aRow.index()
        bIndex = bRow.index()
        # Sort value A
        if cache[aIndex]
          a = cache[aIndex]
        else
          a = sortValueForCell(th, self.cellToSort(a), self)
          cache[aIndex] = a
        # Sort Value B
        if cache[bIndex]
          b = cache[bIndex]
        else
          b = sortValueForCell(th, self.cellToSort(b), self)
          cache[bIndex] = b
        naturalSort(a, b) * direction
      rows.each (i, tr) ->
        fragment.append tr
        return
      table.append fragment.html()
      th.addClass self.settings[self.direction[index]]
      self.log 'Sort finished in ' + (new Date).getTime() - start.getTime() + 'ms'
      self.$table.trigger 'tablesort:complete', [ self ]
      return
    cellToSort: (row) ->
      $ $(row).find('td').get(@index)
    log: (msg) ->
      if ($.tablesort.DEBUG or @settings.debug) and console and console.log
        console.log '[tablesort] ' + msg
      return
    destroy: ->
      @$table.find('thead th').unbind 'click.tablesort'
      @$table.data 'tablesort', null
      null
  $.tablesort.DEBUG = false
  $.tablesort.defaults =
    debug: $.tablesort.DEBUG
    asc: 'sorted ascending'
    desc: 'sorted descending'

  $.fn.tablesort = (settings) ->
    table = undefined
    sortable = undefined
    previous = undefined
    @each ->
      table = $(this)
      previous = table.data('tablesort')
      if previous
        previous.destroy()
      table.data 'tablesort', new ($.tablesort)(table, settings)
      return

  return
) jQuery

# ---
# generated by js2coffee 2.2.0
# Date Calendar

$('#start_date').calendar
  type: 'date'
  monthFirst: false
  initialDate: null
  today: true
  formatter: date: (date, settings) ->
    if !date
      return ''
    day = date.getDate()
    month = date.getMonth() + 1
    year = date.getFullYear()
    year + '-' + month + '-' + day
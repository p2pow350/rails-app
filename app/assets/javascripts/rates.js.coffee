# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$('.ui.sidebar').sidebar 'toggle'
      

$('#xls-export').click ->
  $('#xls-table').table2excel
    name: 'Comparison'
    filename: 'comparison'
  return
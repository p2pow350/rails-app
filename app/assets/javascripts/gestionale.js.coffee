# ---
# General scripts
#console.log 'Application Started'


# Turbolinks compatible
ready = undefined
ready = ->
	
	$('.ui.sidebar').sidebar dimPage: false
	
	dataConfirmModal.setDefaults
	  title: 'Confirm your action'
	  commit: 'Continue'
	  cancel: 'Cancel'
	
	
	$ ->
	  if $('.ui.dropdown').length
		  $('.ui.dropdown').dropdown(fullTextSearch: true)
		  return

	$ ->
      $('.menu-trigger').click ->
      	  $('.ui.sidebar').sidebar 'toggle'
      	  return
		  
	$ ->
      $('table').tablesort()  
	  
      
    $('#upload-button').on 'click', ->
      $('#upload-input').click()
      return
    $('#upload-input').change ->
      $('#upload-form').submit()
      return      
      
  return

#$(document).ready(ready)
#$(document).on('page:load', ready)  
$(document).on 'turbolinks:load', ready


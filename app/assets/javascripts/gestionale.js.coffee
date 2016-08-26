# ---
# General scripts
#console.log 'Application Started'


# Turbolinks compatible
ready = undefined
ready = ->
  
	dataConfirmModal.setDefaults
	  title: 'Confirm your action'
	  commit: 'Continue'
	  cancel: 'Cancel'
	
	
	$ ->
	  if $('.ui.dropdown').length
		  $('.ui.dropdown').dropdown()
		  return

	$ ->
      $('#toggle_menu').click ->
      	  $('.menu.sidebar').sidebar 'toggle'
      	  return
		  
		  
  return

#$(document).ready(ready)
#$(document).on('page:load', ready)  
$(document).on 'turbolinks:load', ready


# config/initializers/lograge.rb
# OR
# config/environments/production.rb
Rails.application.configure do
  config.lograge.enabled = true
  
  # add time and params to lograge
  config.lograge.custom_options = lambda do |event|
  	params = event.payload[:params]
    {:time => event.time, :params => params}
  end  
  
end
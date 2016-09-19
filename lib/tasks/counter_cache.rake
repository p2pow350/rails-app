task code_counter: :environment do
  p 'Counter cache for Zone has many Codes'
  
  Zone.reset_column_information
  Zone.pluck(:id).each do |z|
    Zone.reset_counters z, :codes
  end
end





task rate_counter: :environment do
  p 'Counter cache for Carrier has many Rates'
  
  Carrier.reset_column_information
  Carrier.pluck(:id).each do |c|
    Carrier.reset_counters c, :rates
  end
end
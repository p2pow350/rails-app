task code_counter: :environment do
  p Time.now.to_s + " - Task: Updating Zone Codes counter cache.."
  
  Zone.reset_column_information
  Zone.pluck(:id).each do |z|
    Zone.reset_counters z, :codes
  end
end





task rate_counter: :environment do
  p Time.now.to_s + " - Task: Updating Carrier Rates counter cache.."
  
  Carrier.reset_column_information
  Carrier.pluck(:id).each do |c|
    Carrier.reset_counters c, :rates
  end
end
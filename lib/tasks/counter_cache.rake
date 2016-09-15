desc 'Counter cache for Zone has many Codes'

task code_counter: :environment do
  Zone.reset_column_information
  Zone.pluck(:id).each do |z|
    Zone.reset_counters z, :codes
  end
end



desc 'Counter cache for Carrier has many Rates'

task rate_counter: :environment do
  Carrier.reset_column_information
  Carrier.pluck(:id).each do |c|
    Carrier.reset_counters c, :rates
  end
end
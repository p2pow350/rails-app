desc 'Counter cache for Zone has many codes'

task code_counter: :environment do
  Zone.reset_column_information
  Zone.pluck(:id).each do |z|
    Zone.reset_counters z, :codes
  end
end
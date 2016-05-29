Dir['{import,output}/*.rb'].each {|file| require_relative file }

date = ARGV[0] ? ARGV[0] : Time.now.strftime('%Y-%m-%d')

output_race_list(date)
file_ids = output_race_result(date)

file_ids.each do |file_id|
  output_horse(file_id)
  import_horse(file_id)
  if import_condition(file_id)
    import_entry(file_id)
    import_result(file_id)
    #  import_payoff(file_id)
  end
end

module CommonHelper
  def base_url
    ENV['REMOTE_HOST']
  end

  def client
    @client ||= Capybara.page.driver
  end

  def generate_test_case(params)
    [].tap do |test_cases|
      params.each do |attribute_name, values|
        values.each do |value|
          test_cases << {attribute_name => value}
        end
      end

      if params.keys.size > 1
        test_cases << params.map {|key, values| [key, values.first] }.to_h
      end
    end
  end

  def generate_combinations(keys)
    [].tap do |combinations|
      keys.size.times do |i|
        combinations << keys.combination(i + 1).to_a
      end
    end.flatten(1)
  end

  module_function :client, :generate_test_case, :generate_combinations
end

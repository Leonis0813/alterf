module CommonHelper
  def base_url
    ENV['REMOTE_HOST']
  end

  def client
    @client ||= Capybara.page.driver
  end

  def generate_test_case(params)
    [].tap do |test_cases|
      tmp_test_cases = [].tap do |tests|
        Array.wrap(params[params.keys.first]).each do |value|
          tests << {params.keys.first => value}
        end

        params.keys[1..-1].each do |key|
          tmp_tests = [].tap do |tmp_test|
            tests.each do |test|
              Array.wrap(params[key]).each do |value|
                tmp_test << test.merge(key => value)
              end
            end
          end
          tests = tmp_tests
        end
        break tests
      end
      test_cases << tmp_test_cases
    end.flatten
  end

  module_function :client, :generate_test_case
end

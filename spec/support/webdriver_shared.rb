# coding: utf-8
shared_context 'Webdriver起動' do
  user_id, password = 'test_user_id', 'test_user_pass'

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("#{base_url}/404_path")
    @driver.manage.add_cookie(name: 'algieba', value: Base64.strict_encode64("#{user_id}:#{password}"))
    @wait = Selenium::WebDriver::Wait.new(timeout: 30)
  end
end

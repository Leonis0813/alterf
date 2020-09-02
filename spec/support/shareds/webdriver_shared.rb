# coding: utf-8

shared_context 'Webdriver起動' do
  test_user_id = 'test_user_id'
  test_password = 'test_user_pass'

  before(:all) do
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120
    @driver = Selenium::WebDriver.for :firefox, http_client: client
    @wait = Selenium::WebDriver::Wait.new(timeout: 30)

    @driver.get("#{base_url.sub('/alterf', '')}/login.html")
    user_id = @wait.until { @driver.find_element(:id, 'user_id') }
    user_id.send_keys(test_user_id)
    password = @wait.until { @driver.find_element(:id, 'password') }
    password.send_keys(test_password)
    @driver.find_element(:xpath, '//button[@type="submit"]').click
    @wait.until { @driver.manage.cookie_named('LSID') }
  end
end

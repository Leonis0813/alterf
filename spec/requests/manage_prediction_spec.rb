# coding: utf-8
require 'rails_helper'

describe 'ブラウザで予測する', :type => :request do
  user_id, password = 'test_user_id', 'test_user_pass'
  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("#{base_url}/404_path")
    @driver.manage.add_cookie(:name => 'algieba', :value => Base64.strict_encode64("#{user_id}:#{password}"))
    @wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  end

  describe '予測画面を開く' do
    before(:all) { @driver.get("#{base_url}/predictions") }

    it '予測画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/predictions" }
      is_asserted_by { @driver.find_element(:id, 'prediction_model') }
      is_asserted_by { @driver.find_element(:id, 'type_file').selected? }
      is_asserted_by { @driver.find_element(:xpath, '//input[@id="prediction_test_data"][@type="file"]') }
      is_asserted_by { @driver.find_element(:xpath, '//form/input[@value="実行"]') }
    end

    describe 'テストデータ形式を変更する' do
      before(:all) { @driver.find_element(:id, 'type_url').click }

      it 'URLを指定できること' do
        is_asserted_by { @driver.find_element(:id, 'type_url').selected? }
        is_asserted_by { @driver.find_element(:xpath, '//input[@id="prediction_test_data"][@type="url"]') }
      end
    end
  end
end
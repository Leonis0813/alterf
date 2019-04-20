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

  describe '評価画面を開く' do
    before(:all) { @driver.get("#{base_url}/evaluations") }

    it '評価画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/evaluations" }
      is_asserted_by { @driver.find_element(:id, 'evaluation_model') }
      is_asserted_by { @driver.find_element(:xpath, '//form/input[@value="実行"]') }
    end
  end
end

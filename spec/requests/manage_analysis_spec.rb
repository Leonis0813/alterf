# coding: utf-8
require 'rails_helper'

describe 'ブラウザで分析する', :type => :request do
  user_id, password = 'test_user_id', 'test_user_pass'
  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("#{base_url}/404_path")
    @driver.manage.add_cookie(:name => 'algieba', :value => Base64.strict_encode64("#{user_id}:#{password}"))
    @wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  end

  describe '分析画面を開く' do
    before(:all) { @driver.get("#{base_url}/analyses") }

    it '分析画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/analyses" }
    end
  end

  describe '不正な値を入力する' do
    before(:all) do
      @driver.find_element(:id, 'analysis_num_data').send_keys('invalid')
      @driver.find_element(:id, 'analysis_num_tree').send_keys(1)
      @driver.find_element(:xpath, '//form/input[@value="実行"]').click
      @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
    end

    it 'タイトルが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="modal-header"]/h4[@class="modal-title"]').text == 'エラーが発生しました' }
    end

    it 'エラーメッセージが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="modal-body"]/div').text == '入力値を見直してください' }
    end
  end
end

# coding: utf-8
require 'rails_helper'

describe "ブラウザで管理する", :type => :request do
  before(:all) { @driver = Selenium::WebDriver.for :firefox }

  describe '管理画面を開く' do
    before(:all) { @driver.get("#{base_url}/analysis") }

    it '管理画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/analysis" }
    end
  end

  describe '不正な値を入力する' do
    before(:all) do
      @driver.find_element(:id, 'analysis_num_data').send_keys('invalid')
      @driver.find_element(:id, 'analysis_num_tree').send_keys(1)
      @driver.find_element(:id, 'analysis_num_feature').send_keys(1)
      @driver.find_element(:xpath, '//form/span/input[@value="実行"]').click
      sleep 1
    end

    it 'タイトルが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="modal-header"]/h4[@class="modal-title"]').text == 'エラーが発生しました' }
    end

    it 'エラーメッセージが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="modal-body"]/div').text == '入力値を見直してください' }
    end
  end
end

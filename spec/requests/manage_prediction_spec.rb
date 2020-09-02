# coding: utf-8

require 'rails_helper'

describe 'ブラウザで予測する', type: :request do
  include_context 'Webdriver起動'

  describe '予測画面を開く' do
    before(:all) do
      retry_times = 0
      begin
        @driver.get("#{base_url}/predictions")
      rescue Net::ReadTimeout
        raise if retry_times > 3

        retry_times += 1
        retry
      end
    end

    it '予測画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/predictions" }
      is_asserted_by { @driver.find_element(:id, 'prediction_model') }
      is_asserted_by { @driver.find_element(:id, 'type_file').selected? }

      xpath = '//input[@id="prediction_test_data"][@type="file"]'
      is_asserted_by { @driver.find_element(:xpath, xpath) }
      is_asserted_by { @driver.find_element(:xpath, '//form/input[@value="実行"]') }
    end

    describe '不正な値を入力する' do
      before(:all) do
        @driver.find_element(:id, 'type_url').click
        @driver.find_element(:id, 'prediction_test_data').send_keys('invalid')
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
      end

      it 'タイトルが正しいこと' do
        xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
        text = 'エラーが発生しました'
        is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
      end

      it 'エラーメッセージが正しいこと' do
        xpath = '//div[@class="modal-body"]/div'
        text = '入力値を見直してください'
        is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
      end

      describe 'テストデータ形式を変更する' do
        before(:all) do
          @driver.get("#{base_url}/predictions")
          @driver.find_element(:id, 'type_url').click
        end

        it 'URLを指定できること' do
          is_asserted_by { @driver.find_element(:id, 'type_url').selected? }

          xpath = '//input[@id="prediction_test_data"][@type="url"]'
          is_asserted_by { @driver.find_element(:xpath, xpath) }
        end
      end
    end
  end
end

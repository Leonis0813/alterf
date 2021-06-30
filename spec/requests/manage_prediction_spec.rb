# coding: utf-8

require 'rails_helper'

describe 'ブラウザで予測する', type: :request do
  include_context 'Webdriver起動'

  describe '予測画面を開く' do
    before(:all) { @driver.get("#{base_url}/predictions") }

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
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:id, 'dialog-execute-error').displayed? }
        @dialog = @driver.find_element(:id, 'dialog-execute-error')
      end

      it_behaves_like 'ダイアログが正しく表示されていること',
                      'エラーが発生しました',
                      '入力値を見直してください'

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

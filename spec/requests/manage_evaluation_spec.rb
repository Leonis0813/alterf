# coding: utf-8

require 'rails_helper'

describe 'ブラウザで予測する', type: :request do
  include_context 'Webdriver起動'

  describe '評価画面を開く' do
    before(:all) { @driver.get("#{base_url}/evaluations") }

    it '評価画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/evaluations" }
      is_asserted_by { @driver.find_element(:id, 'evaluation_model') }
      is_asserted_by { @driver.find_element(:xpath, '//form/input[@value="実行"]') }
    end

    describe 'モデルを指定せずに実行する' do
      before(:all) do
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
    end
  end
end

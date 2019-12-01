# coding: utf-8

require 'rails_helper'

describe 'ブラウザで分析する', type: :request do
  include_context 'Webdriver起動'

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
      xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
      text = 'エラーが発生しました'
      is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
    end

    it 'エラーメッセージが正しいこと' do
      xpath = '//div[@class="modal-body"]/div'
      text = '入力値を見直してください'
      is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
    end

    describe 'エントリー数を指定せずに分析を実行する' do
      before(:all) do
        @driver.get("#{base_url}/analyses")
        @driver.find_element(:id, 'analysis_num_data').send_keys(100)
        @driver.find_element(:id, 'analysis_num_tree').send_keys(10)
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
      end

      it 'タイトルが正しいこと' do
        xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
        text = '分析を開始しました'
        is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
      end

      it 'ダイアログのメッセージが正しいこと' do
        xpath = '//div[@class="modal-body"]/div'
        text = '終了後、メールにて結果を通知します'
        is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
      end
    end

    describe 'エントリー数を指定して分析を実行する' do
      before(:all) do
        @driver.get("#{base_url}/analyses")
        @driver.find_element(:id, 'analysis_num_data').send_keys(100)
        @driver.find_element(:id, 'analysis_num_tree').send_keys(10)
        @driver.find_element(:id, 'analysis_num_entry').send_keys(10)
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
      end

      it 'タイトルが正しいこと' do
        xpath = '//div[@class="modal-header"]/h4[@class="modal-title"]'
        text = '分析を開始しました'
        is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
      end

      it 'ダイアログのメッセージが正しいこと' do
        xpath = '//div[@class="modal-body"]/div'
        text = '終了後、メールにて結果を通知します'
        is_asserted_by { @driver.find_element(:xpath, xpath).text == text }
      end
    end
  end
end

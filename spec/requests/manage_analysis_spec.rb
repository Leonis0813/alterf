# coding: utf-8

require 'rails_helper'

describe 'ブラウザで分析する', type: :request do
  shared_examples 'ダイアログが正しく表示されていること' do |title, message|
    it 'タイトルが正しいこと' do
      xpath = '//h4[@class="modal-title"]'
      is_asserted_by { @dialog.find_element(:xpath, xpath).text == title }
    end

    it 'メッセージが正しいこと' do
      xpath = '//div[@class="modal-body"]'
      is_asserted_by { @dialog.find_element(:xpath, xpath).text == message }
    end
  end

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
      @driver.find_element(:xpath, '//form/input[@value="実行"]').click
      @wait.until { @driver.find_element(:id, 'dialog-execute-error').displayed? }
      @dialog = @driver.find_element(:id, 'dialog-execute-error')
    end

    it_behaves_like 'ダイアログが正しく表示されていること',
                    'エラーが発生しました',
                    '入力値を見直してください'

    describe 'エントリー数を指定せずに分析を実行する' do
      before(:all) do
        @driver.get("#{base_url}/analyses")
        @driver.find_element(:id, 'analysis_num_data').send_keys(100)
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:id, 'dialog-execute').displayed? }
        @dialog = @driver.find_element(:id, 'dialog-execute')
      end

      it_behaves_like 'ダイアログが正しく表示されていること',
                      '分析を開始しました',
                      '終了後、メールにて結果を通知します'
    end

    describe 'エントリー数を指定して分析を実行する' do
      before(:all) do
        @driver.get("#{base_url}/analyses")
        @driver.find_element(:id, 'analysis_num_data').send_keys(100)
        @driver.find_element(:id, 'analysis_num_entry').send_keys(10)
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:id, 'dialog-execute').displayed? }
        @dialog = @driver.find_element(:id, 'dialog-execute')
      end

      it_behaves_like 'ダイアログが正しく表示されていること',
                      '分析を開始しました',
                      '終了後、メールにて結果を通知します'
    end

    describe 'パラメーターを指定して分析を実行する' do
      before(:all) do
        @driver.get("#{base_url}/analyses")
        @driver.find_element(:id, 'analysis_num_data').send_keys(100)
        @driver.find_element(:id, 'collapse-parameter').click
        num_tree = @driver.find_element(:id, 'analysis_parameter_attributes_num_tree')
        num_tree.clear
        num_tree.send_keys(10)
        @driver.find_element(:xpath, '//form/input[@value="実行"]').click
        @wait.until { @driver.find_element(:id, 'dialog-execute').displayed? }
        @dialog = @driver.find_element(:id, 'dialog-execute')
      end

      it_behaves_like 'ダイアログが正しく表示されていること',
                      '分析を開始しました',
                      '終了後、メールにて結果を通知します'

      describe '確認ダイアログを表示する' do
        before(:all) do
          @driver.get("#{base_url}/analyses")
          @driver.find_element(:xpath, '//td[contains(@class, "btn-param")]').click
        end

        it 'パラメーター確認ダイアログが表示されていること' do
          xpath = '//div[@id="dialog-parameter"]//h4[@class="modal-title"]'
          title = 'パラメーター'
          is_asserted_by { @driver.find_element(:xpath, xpath).text == title }
        end

        it 'パラメーターが表示されていること' do
          xpath = '//div[@id="dialog-parameter"]//td[@id="parameter-num_tree"]'
          is_asserted_by { @driver.find_element(:xpath, xpath.text == '10') }
        end
      end
    end
  end
end

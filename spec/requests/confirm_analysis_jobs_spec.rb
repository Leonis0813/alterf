# coding: utf-8

require 'rails_helper'

describe 'ジョブ情報を確認する', type: :request do
  include_context 'Webdriver起動'

  describe '分析画面を開く' do
    before(:all) { @driver.get("#{base_url}/analyses") }

    it '分析画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/analyses" }
    end
  end

  describe '不正な値を入力する' do
    before(:all) do
      @driver.find_element(:id, 'tab-index').click
      @driver.find_element(:id, 'input-index-num_data').send_keys('invalid')
      @driver.find_element(:xpath, '//form/input[@value="検索"]').click
      @wait.until { @driver.find_element(:id, 'dialog-execute-error').displayed? }
      @dialog = @driver.find_element(:id, 'dialog-execute-error')
    end

    it_behaves_like 'ダイアログが正しく表示されていること',
                    'エラーが発生しました',
                    '入力値を見直してください'

    describe '分析ジョブ情報を検索する' do
      before(:all) do
        @wait.until do
          @driver.find_element(:id, 'btn-modal-execute-error-ok').click
          not @driver.find_element(:id, 'dialog-execute-error').displayed?
        end
        element = @driver.find_element(:id, 'input-index-num_data')
        element.clear
        element.send_keys('1')
        @wait.until do
          @driver.find_element(:xpath, '//form/input[@value="検索"]').click.nil?
        end
      end

      it '分析ジョブ一覧が表示されていること' do
        is_asserted_by do
          @wait.until { @driver.find_element(:id, 'table-analysis').displayed? }
        end
      end
    end
  end
end

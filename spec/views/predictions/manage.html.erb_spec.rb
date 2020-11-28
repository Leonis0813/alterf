# coding: utf-8

require 'rails_helper'

describe 'predictions/manage', type: :view do
  include PredictionViewHelper

  test_data = 'https://db.netkeiba.com/race/123456'

  before(:all) do
    Kaminari.config.default_per_page = PredictionViewHelper::DEFAULT_PER_PAGE
    @prediction = Prediction.new
  end

  before do
    render template: 'predictions/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    attribute = {test_data: test_data}
    include_context 'トランザクション作成'
    include_context '予測ジョブを作成する', update_attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'テストデータがリンクになっていること'
    it_behaves_like 'ジョブが実行待ち状態になっていること'
  end

  context '実行中の場合' do
    attribute = {test_data: test_data, state: 'processing', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '予測ジョブを作成する', update_attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'テストデータがリンクになっていること'
    it_behaves_like 'ジョブが実行中状態になっていること'
  end

  context '完了している場合' do
    attribute = {state: 'completed', performed_at: Time.zone.now}

    context '番号の数が6個の場合' do
      include_context 'トランザクション作成'
      include_context '予測ジョブを作成する', update_attribute: attribute, results: 6
      include_context 'HTML初期化'
      it_behaves_like '予測画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'テーブルに予測結果が表示されていること', numbers: 6
    end

    context '番号の数が7個の場合' do
      include_context 'トランザクション作成'
      include_context '予測ジョブを作成する', update_attribute: attribute, results: 7
      include_context 'HTML初期化'
      it_behaves_like '予測画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'テーブルに予測結果が表示されていること', numbers: 7
    end
  end

  context 'エラーの場合' do
    attribute = {state: 'error', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '予測ジョブを作成する', update_attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブがエラー状態になっていること'
  end

  total = PredictionViewHelper::DEFAULT_PER_PAGE * (Kaminari.config.window + 2)
  context "予測ジョブ情報が#{total}件の場合" do
    include_context 'トランザクション作成'
    include_context '予測ジョブを作成する', total: total
    include_context 'HTML初期化'
    it_behaves_like '予測画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること'
  end
end

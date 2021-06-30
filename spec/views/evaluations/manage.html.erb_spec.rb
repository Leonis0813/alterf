# coding: utf-8

require 'rails_helper'

describe 'evaluations/manage', type: :view do
  include EvaluationViewHelper

  before(:all) do
    Kaminari.config.default_per_page = EvaluationViewHelper::DEFAULT_PER_PAGE
    @evaluation = Evaluation.new
  end

  before do
    render template: 'evaluations/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する'
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'テーブルの列がリンクになっていないこと'
    it_behaves_like '実行開始時間が表示されていないこと'
    it_behaves_like '評価ジョブの情報が表示されていること', state: '実行待ち'
    it_behaves_like 'ダウンロードボタンが表示されていないこと'
  end

  context '実行中の場合' do
    attribute = {state: 'processing', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する', update_attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'テーブルの列がリンクになっていること'
    it_behaves_like '評価ジョブの情報が表示されていること', state: '0%完了'
    it_behaves_like 'ダウンロードボタンが表示されていないこと'
  end

  context '完了している場合' do
    attribute = {
      state: 'completed',
      precision: 0.75,
      recall: 0.5,
      f_measure: 0.6,
      performed_at: Time.zone.now,
    }

    %w[file text].each do |data_source|
      context "data_sourceが#{data_source}の場合" do
        include_context 'トランザクション作成'
        include_context '評価ジョブを作成する',
                        update_attribute: attribute.merge(data_source: data_source)
        include_context 'HTML初期化'
        it_behaves_like '評価画面共通テスト'
        it_behaves_like 'ページングボタンが表示されていないこと'
        it_behaves_like 'テーブルの列がリンクになっていること'
        it_behaves_like '評価ジョブの情報が表示されていること', state: '完了'
        it_behaves_like '評価結果情報が表示されていること'
        it_behaves_like 'ダウンロードボタンが表示されていないこと'
      end
    end

    %w[remote random].each do |data_source|
      context "data_sourceが#{data_source}の場合" do
        include_context 'トランザクション作成'
        include_context '評価ジョブを作成する',
                        update_attribute: attribute.merge(data_source: data_source)
        include_context 'HTML初期化'
        it_behaves_like '評価画面共通テスト'
        it_behaves_like 'ページングボタンが表示されていないこと'
        it_behaves_like 'テーブルの列がリンクになっていること'
        it_behaves_like '評価ジョブの情報が表示されていること', state: '完了'
        it_behaves_like '評価結果情報が表示されていること'
        it_behaves_like 'ダウンロードボタンが表示されていること'
      end
    end
  end

  context 'エラーの場合' do
    attribute = {state: 'error', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する', update_attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'テーブルの列がリンクになっていないこと'
    it_behaves_like '評価ジョブの情報が表示されていること', state: 'エラー'
    it_behaves_like 'ダウンロードボタンが表示されていないこと'
  end

  total = EvaluationViewHelper::DEFAULT_PER_PAGE * (Kaminari.config.window + 2)
  context "評価ジョブ情報が#{total}件の場合" do
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する', total: total
    include_context 'HTML初期化'
    it_behaves_like '評価画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること'
  end
end

# coding: utf-8

require 'rails_helper'

describe 'analyses/manage', type: :view do
  include AnalysisViewHelper

  before(:all) do
    Kaminari.config.default_per_page = AnalysisViewHelper::DEFAULT_PER_PAGE
    @analysis = Analysis.new
    @analysis.build_parameter
  end

  before do
    render template: 'analyses/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行待ち'
  end

  context '実行中の場合' do
    update_attribute = {state: 'processing', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行中'
  end

  context 'エントリー数が指定されている場合' do
    update_attribute = {num_entry: 10, state: 'processing', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行中', num_entry: 10
  end

  context '完了している場合' do
    update_attribute = {state: 'completed', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '完了'
  end

  context 'エラーの場合' do
    update_attribute = {state: 'error', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', 'エラー'
  end

  total = AnalysisViewHelper::DEFAULT_PER_PAGE * (Kaminari.config.window + 2)
  context "分析ジョブ情報が#{total}件の場合", :wip do
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', total: total
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること'
  end
end

# coding: utf-8

require 'rails_helper'

describe Api::Analyses::Result::DecisionTreesController, type: :controller do
  render_views

  shared_context 'リクエスト送信' do
    before do
      params = {analysis_id: @analysis_id, decision_tree_id: @decision_tree_id}
      response = get(:show, params: params, format: :json)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    before do
      analysis = create(:analysis)
      @analysis_id = analysis.analysis_id

      decision_tree = analysis.result.decision_trees.first
      @decision_tree_id = decision_tree.decision_tree_id

      @body = {
        decision_tree_id: decision_tree.decision_tree_id,
        nodes: decision_tree.nodes.map do |node|
          node.slice(
            :node_id,
            :node_type,
            :group,
            :feature_name,
            :threshold,
            :num_win,
            :num_lose,
          ).merge(parent_node_id: node.parent_id)
        end,
      }.deep_stringify_keys
    end
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正常であること', status: 200
  end

  describe '異常系' do
    include_context 'トランザクション作成'
    before do
      @analysis = create(:analysis)
      @analysis_id = @analysis.analysis_id
      @decision_tree_id = @analysis.result.decision_trees.first.decision_tree_id
    end

    context '分析ジョブが存在しない場合' do
      before { @analysis_id = 'not_exist' }
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 404
    end

    context '分析結果が存在しない場合' do
      before { @analysis.result.destroy }
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 404
    end

    context '決定木情報が存在しない場合' do
      before { @decision_tree_id = 'not_exist' }
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 404
    end
  end
end

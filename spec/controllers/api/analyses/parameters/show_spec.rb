# coding: utf-8

require 'rails_helper'

describe Api::Analyses::ParametersController, type: :controller do
  describe '#show' do
    render_views

    shared_context 'リクエスト送信' do
      before do
        response = get(:show, params: {analysis_id: @analysis_id}, format: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    describe '正常系' do
      include_context 'トランザクション作成'
      before do
        analysis = create(:analysis)
        @analysis_id = analysis.analysis_id
        @body = analysis.parameter.slice(
          :max_depth,
          :max_features,
          :max_leaf_nodes,
          :min_samples_leaf,
          :min_samples_split,
          :num_tree
        ).deep_stringify_keys
      end
      include_context 'リクエスト送信'
      it_behaves_like 'レスポンスが正常であること', status: 200
    end

    describe '異常系' do
      before { @analysis_id = 'not_exist' }
      include_context 'リクエスト送信'

      it 'ステータスコードが正しいこと' do
        is_asserted_by { @response_status == 404 }
      end
    end
  end
end

# coding: utf-8

require 'rails_helper'

describe Api::AnalysesController, type: :controller do
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

      result = {
        importances: analysis.result.importances.map do |importance|
          importance.slice(:feature_name, :value)
        end,
      }
      @body = analysis.slice(
        :analysis_id,
        :num_data,
        :num_tree,
        :num_feature,
        :num_entry,
        :performed_at,
        :state,
      ).merge(result: result).deep_stringify_keys
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

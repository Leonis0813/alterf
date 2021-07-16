# coding: utf-8

require 'rails_helper'

describe Api::Analyses::Result::ImportancesController, type: :controller do
  render_views

  shared_context 'リクエスト送信' do
    before do
      response = get(:index, params: {analysis_id: @analysis_id}, format: :json)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    before do
      analysis = create(:analysis)
      @analysis_id = analysis.analysis_id

      @body = {
        importances: analysis.result.importances.map do |importance|
          importance.slice(:feature_name, :value)
        end,
      }.deep_stringify_keys
    end
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正常であること', status: 200
  end

  describe '異常系' do
    context '分析ジョブが存在しない場合' do
      before { @analysis_id = 'not_exist' }
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 404
    end

    context '分析結果が存在しない場合' do
      include_context 'トランザクション作成'
      before do
        analysis = create(:analysis)
        @analysis_id = analysis.analysis_id
        analysis.result.destroy
      end
      include_context 'リクエスト送信'
      it_behaves_like 'ステータスコードが正しいこと', 404
    end
  end
end

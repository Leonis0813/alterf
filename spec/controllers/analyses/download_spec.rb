# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  tmp_dir = Rails.root.join('tmp/files/analyses')

  shared_context '分析結果を作成する' do
    include_context 'トランザクション作成'
    before do
      @analysis = create(:analysis)
      dest_dir = File.join(tmp_dir, @analysis.id.to_s)
      FileUtils.mkdir_p(dest_dir)
      FileUtils.cp(Rails.root.join('spec', 'fixtures', 'result.zip'), dest_dir)
    end
  end

  shared_context 'リクエスト送信' do |analysis_id = nil|
    before do
      analysis_id ||= @analysis.analysis_id
      params = {param: :analysis_id, analysis_id: analysis_id}
      response = get(:download, params: params)
      @response_status = response.status
      @response_body = response.body
    end
  end

  describe '正常系' do
    before { FileUtils.rm_rf(Dir[File.join(tmp_dir, '*')]) }
    after { FileUtils.rm_rf(Dir[File.join(tmp_dir, '*')]) }
    include_context '分析結果を作成する'
    include_context 'リクエスト送信'

    it 'ステータスコードが正しいこと' do
      is_asserted_by { @response_status == 200 }
    end
  end

  describe '異常系' do
    context '分析結果が存在しない場合' do
      include_context 'リクエスト送信', 'not_exist'
      it_behaves_like 'レスポンスが正常であること', status: 404, body: ''
    end

    context '分析結果ファイルが存在しない場合' do
      include_context '分析結果を作成する'
      before { FileUtils.rm(File.join(tmp_dir, @analysis.id.to_s, 'result.zip')) }
      include_context 'リクエスト送信'
      it_behaves_like 'レスポンスが正常であること', status: 404, body: ''
    end
  end
end

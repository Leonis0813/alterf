# coding: utf-8

require 'rails_helper'

describe EvaluationsController, type: :controller do
  tmp_dir = Rails.root.join('tmp/files/evaluations')
  file_body = '1' * 8

  shared_context '評価データを作成する' do
    include_context 'トランザクション作成'
    before(:all) do
      @evaluation = create(:evaluation)
      output_dir = File.join(tmp_dir, @evaluation.id.to_s)
      FileUtils.mkdir_p(output_dir)
      File.open(File.join(output_dir, 'data.txt'), 'w') do |file|
        file.puts(file_body)
      end
    end
  end

  shared_context 'リクエスト送信' do |evaluation_id = nil|
    before(:all) do
      evaluation_id ||= @evaluation.evaluation_id
      response = client.get("/evaluations/#{evaluation_id}/download")
      @response_status = response.status
      @response_body = response.body
    end
  end

  describe '正常系' do
    before(:all) { FileUtils.rm_rf(Dir[File.join(tmp_dir, '*')]) }
    after(:all) { FileUtils.rm_rf(Dir[File.join(tmp_dir, '*')]) }
    include_context '評価データを作成する'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正常であること', status: 200, body: "#{file_body}\n"
  end

  describe '異常系' do
    context '評価ジョブが存在しない場合' do
      include_context 'リクエスト送信', 'not_exist'
      it_behaves_like 'レスポンスが正常であること', status: 404, body: ''
    end

    context '評価データファイルが存在しない場合' do
      include_context '評価データを作成する'
      before(:all) { FileUtils.rm(File.join(tmp_dir, @evaluation.id.to_s, 'data.txt')) }
      include_context 'リクエスト送信'
      it_behaves_like 'レスポンスが正常であること', status: 404, body: ''
    end
  end
end

# coding: utf-8

require 'rails_helper'

describe EvaluationsController, type: :controller do
  model_file_path = Rails.root.join('spec', 'fixtures', 'model.txt')
  model = Rack::Test::UploadedFile.new(File.open(model_file_path))
  default_params = {model: model}

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(EvaluationJob).to receive(:perform_later).and_return(true)
        response = client.post('/evaluations', body)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue nil
      end
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
    it_behaves_like 'DBにレコードが追加されていること',
                    Evaluation, {model: model.original_filename}
  end

  describe '異常系' do
    context 'modelがない場合' do
      body = [{'error_code' => 'absent_param_model'}]
      include_context 'リクエスト送信', body: {}
      it_behaves_like 'レスポンスが正常であること', status: 400, body: body
      it_behaves_like 'DBにレコードが追加されていないこと',
                      Evaluation, {model: model.original_filename}
    end

    context 'modelが不正な場合' do
      body = [{'error_code' => 'invalid_param_model'}]
      include_context 'リクエスト送信', body: {model: 'invalid'}
      it_behaves_like 'レスポンスが正常であること', status: 400, body: body
      it_behaves_like 'DBにレコードが追加されていないこと',
                      Evaluation, {model: model.original_filename}
    end
  end
end

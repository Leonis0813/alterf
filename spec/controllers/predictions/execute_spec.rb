# coding: utf-8

require 'rails_helper'

describe PredictionsController, type: :controller do
  model_file_path = Rails.root.join('spec', 'fixtures', 'model.txt')
  model = Rack::Test::UploadedFile.new(File.open(model_file_path))
  test_data_file_path = Rails.root.join('spec', 'fixtures', 'test_data.txt')
  test_data = {
    file: Rack::Test::UploadedFile.new(File.open(test_data_file_path)),
    url: 'http://example.com',
  }
  default_params = {model: model, test_data: test_data[:file]}

  shared_context 'リクエスト送信' do |body: {}|
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(PredictionJob).to receive(:perform_later).and_return(true)
        response = client.post('/predictions', body)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue nil
      end
    end
  end

  describe '正常系' do
    %i[file url].each do |type|
      context "テストデータの種類が#{type}の場合" do
        body = default_params.merge(test_data: test_data[type])
        include_context 'トランザクション作成'
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
        it_behaves_like 'DBにレコードが追加されていること',
                        Prediction, model: model.original_filename
      end
    end
  end

  describe '異常系' do
    test_cases = [].tap do |tests|
      (default_params.keys.size - 1).times do |i|
        tests << default_params.keys.combination(i + 1).to_a
      end
    end.flatten(1)

    test_cases.each do |error_keys|
      context "#{error_keys.join(',')}がない場合" do
        selected_keys = default_params.keys - error_keys
        body = error_keys.map {|key| {'error_code' => "absent_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.slice(*selected_keys)
        it_behaves_like 'レスポンスが正常であること', status: 400, body: body
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Prediction, model: model.original_filename
      end

      context "#{error_keys.join(',')}が不正な場合" do
        invalid_params = error_keys.map {|key| [key, 'invalid'] }.to_h
        body = error_keys.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.merge(invalid_params)
        it_behaves_like 'レスポンスが正常であること', status: 400, body: body
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Prediction, model: model.original_filename
      end
    end
  end
end

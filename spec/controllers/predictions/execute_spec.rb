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
  default_params = {model: model, test_data: test_data[:file], type: 'file'}

  shared_context 'リクエスト送信' do |body: {}|
    before do
      allow(PredictionJob).to receive(:perform_later).and_return(true)
      response = client.post('/predictions', body)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  describe '正常系' do
    %i[file url].each do |type|
      context "テストデータの種類が#{type}の場合" do
        body = default_params.merge(test_data: test_data[type], type: type.to_s)
        include_context 'トランザクション作成'
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
        it_behaves_like 'DBにレコードが追加されていること',
                        Prediction, model: model.original_filename
      end
    end
  end

  describe '異常系' do
    required_keys = default_params.keys

    CommonHelper.generate_combinations(required_keys).each do |absent_keys|
      context "#{absent_keys.join(',')}がない場合" do
        selected_keys = required_keys - absent_keys
        errors = absent_keys.map do |key|
          {
            'error_code' => 'absent_parameter',
            'parameter' => key.to_s,
            'resource' => 'prediction',
          }
        end
        errors.sort_by! {|error| [error['error_code'], error['parameter']] }

        include_context 'リクエスト送信', body: default_params.slice(*selected_keys)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Prediction, model: model.original_filename
      end
    end

    invalid_attribute = {
      type: ['invalid', %w[file], {type: 'file'}, nil],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        errors = invalid_param.keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => 'prediction',
          }
        end
        errors.sort_by! {|error| [error['error_code'], error['parameter']] }

        include_context 'リクエスト送信', body: default_params.merge(invalid_param)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Prediction, model: model.original_filename
      end
    end

    [
      [{model: 'invalid', type: 'file'}, %i[model]],
      [{model: 'invalid', type: 'url', test_data: test_data[:url]}, %i[model]],
      [{type: 'file', test_data: 'invalid'}, %i[test_data]],
      [{type: 'url', test_data: 'invalid'}, %i[test_data]],
      [{type: 'url', test_data: test_data[:file]}, %i[test_data]],
      [{model: 'invalid', type: 'file', test_data: 'invalid'}, %i[model test_data]],
    ].each do |param, invalid_keys|
      context "#{invalid_keys.join(',')}が不正な場合" do
        errors = invalid_keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => 'prediction',
          }
        end
        errors.sort_by! {|error| [error['error_code'], error['parameter']] }

        include_context 'リクエスト送信', body: default_params.merge(param)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
      end
    end

    context '複合エラーの場合' do
      errors = [
        {
          'error_code' => 'absent_parameter',
          'parameter' => 'model',
          'resource' => 'prediction',
        },
        {
          'error_code' => 'invalid_parameter',
          'parameter' => 'type',
          'resource' => 'prediction',
        },
      ]

      include_context 'リクエスト送信', body: {type: 'invalid', test_data: 'test_data'}
      it_behaves_like 'レスポンスが正常であること',
                      status: 400, body: {'errors' => errors}
    end
  end
end

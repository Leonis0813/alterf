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

  describe '正常系' do
    %i[file url].each do |type|
      context "テストデータの種類が#{type}の場合" do
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(PredictionJob).to receive(:perform_later).and_return(true)
            body = default_params.merge(test_data: test_data[type])
            @res = client.post('/predictions', body)
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        after(:all) { Prediction.destroy_all }

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it 'レスポンスが空であること' do
          is_asserted_by { @pbody == {} }
        end
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
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(PredictionJob).to receive(:perform_later).and_return(true)
            @res = client.post('/predictions', default_params.slice(*selected_keys))
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it '400エラーが返ること' do
          is_asserted_by { @res.status == 400 }
        end

        it 'エラーメッセージが正しいこと' do
          error_codes = error_keys.map {|key| {'error_code' => "absent_param_#{key}"} }
          is_asserted_by { JSON.parse(@res.body) == error_codes }
        end
      end

      context "#{error_keys.join(',')}が不正な場合" do
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(PredictionJob).to receive(:perform_later).and_return(true)
            params = default_params.dup
            error_keys.each {|key| params.merge!(key => 'invalid') }
            @res = client.post('/predictions', params)
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it '400エラーが返ること' do
          is_asserted_by { @res.status == 400 }
        end

        it 'エラーメッセージが正しいこと' do
          error_codes = error_keys.map {|key| {'error_code' => "invalid_param_#{key}"} }
          is_asserted_by { JSON.parse(@res.body) == error_codes }
        end
      end

      context 'テストデータのURLが不正な場合' do
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(PredictionJob).to receive(:perform_later).and_return(true)
            body = default_params.merge(test_data: 'invalid_url')
            @res = client.post('/predictions', body)
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it '400エラーが返ること' do
          is_asserted_by { @res.status == 400 }
        end

        it 'エラーメッセージが正しいこと' do
          error_codes = [{'error_code' => 'invalid_param_test_data'}]
          is_asserted_by { JSON.parse(@res.body) == error_codes }
        end
      end
    end
  end
end

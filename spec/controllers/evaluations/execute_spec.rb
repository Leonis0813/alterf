# coding: utf-8

require 'rails_helper'

describe EvaluationsController, type: :controller do
  model_file_path = Rails.root.join('spec', 'fixtures', 'model.txt')
  model = Rack::Test::UploadedFile.new(File.open(model_file_path))
  race_list_file_path = Rails.root.join('spec', 'fixtures', 'race_list.txt')
  data = Rack::Test::UploadedFile.new(File.open(race_list_file_path))
  default_params = {model: model, data_source: 'remote'}
  tmp_dir = Rails.root.join('tmp', 'files', 'evaluations')

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(EvaluationJob).to receive(:perform_later).and_return(true)
        response = client.post('/evaluations', body)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end
  end

  describe '正常系' do
    before(:all) { FileUtils.rm_rf(Dir[File.join(tmp_dir, '*')]) }
    after(:all) { FileUtils.rm_rf(Dir[File.join(tmp_dir, '*')]) }
    include_context 'トランザクション作成'
    include_context 'リクエスト送信'
    it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
    it_behaves_like 'DBにレコードが追加されていること',
                    Evaluation, model: model.original_filename, data_source: 'remote'

    [
      {data_source: 'file', data: data},
      {data_source: 'random', num_data: 100},
      {data_source: 'remote'},
      {data_source: 'text', data: "test\n"},
    ].each do |data_body|
      user_specified_data = %w[file text].include?(data_body[:data_source])

      context "data_sourceに#{data_body[:data_source]}を指定した場合" do
        query = {model: model.original_filename, data_source: data_body[:data_source]}
        include_context 'トランザクション作成'
        include_context 'リクエスト送信', body: default_params.merge(data_body)
        it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
        it_behaves_like 'DBにレコードが追加されていること', Evaluation, query

        it '評価データがファイルに保存されていること', if: user_specified_data do
          evaluation = Evaluation.find_by(query)
          output_file_path = File.join(
            tmp_dir,
            evaluation.id.to_s,
            Settings.evaluation.race_list_filename,
          )
          is_asserted_by { File.exist?(output_file_path) }
          is_asserted_by { File.read(output_file_path) == "test\n" }
        end
      end
    end
  end

  describe '異常系' do
    [
      %i[model],
      %i[data_source],
      %i[model data_source],
    ].each do |error_keys|
      context "#{error_keys.join(',')}がない場合" do
        errors = error_keys.map {|key| {'error_code' => "absent_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.except(*error_keys)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Evaluation, model: model.original_filename, data_source: 'remote'
      end
    end

    [
      [{model: 'invalid'}, %w[model]],
      [{data_source: 'invalid'}, %w[num_data data_source]],
    ].each do |error_body, error_keys|
      context "#{error_body.keys.join(',')}が不正な場合" do
        errors = error_keys.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.merge(error_body)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Evaluation, model: model.original_filename, data_source: 'remote'
      end
    end

    [
      {data_source: 'text', data: ''},
      {data_source: 'text', data: "\ntest"},
    ].each do |error_data|
      context "dataが不正な場合(#{error_data})" do
        errors = [{'error_code' => 'invalid_param_data'}]
        include_context 'リクエスト送信', body: default_params.merge(error_data)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと',
                        Evaluation,
                        model: model.original_filename,
                        data_source: error_data[:data_source]
      end
    end
  end
end

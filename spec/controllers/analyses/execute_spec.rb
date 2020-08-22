# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  default_params = {num_data: '1000', num_tree: '100'}

  shared_context 'リクエスト送信' do |body: default_params|
    before do
      allow(AnalysisJob).to receive(:perform_later).and_return(true)
      response = client.post('/analyses', body)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end
  end

  describe '正常系' do
    [default_params, default_params.merge(num_entry: '9')].each do |body|
      context "body: #{body}の場合" do
        include_context 'トランザクション作成'
        include_context 'リクエスト送信', body: body
        before { @analysis = Analysis.find_by(body.merge(state: 'waiting')) }

        it_behaves_like 'レスポンスが正常であること', status: 200, body: {}

        it 'DBに分析ジョブが登録されていること' do
          is_asserted_by { @analysis.present? }
        end

        it 'DBに分析結果が登録されていること' do
          is_asserted_by { @analysis.result.present? }
        end
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
            'resource' => 'analysis',
          }
        end.sort_by {|error| [error['error_code'], error['parameter']] }
        include_context 'リクエスト送信', body: default_params.slice(*selected_keys)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと', Analysis, default_params
      end
    end

    invalid_attribute = {
      num_data: ['invalid', [1], {data: 1}, nil],
      num_tree: ['invalid', [1], {tree: 1}, nil],
      num_entry: ['invalid', [1], {entry: 1}, nil],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        errors = invalid_param.keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => 'analysis',
          }
        end.sort_by {|error| [error['error_code'], error['parameter']] }
        include_context 'リクエスト送信', body: default_params.merge(invalid_param)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと', Analysis, default_params
      end
    end

    context '複合エラーの場合' do
      errors = [
        {
          'error_code' => 'absent_parameter',
          'parameter' => 'num_data',
          'resource' => 'analysis',
        },
        {
          'error_code' => 'invalid_parameter',
          'parameter' => 'num_tree',
          'resource' => 'analysis',
        },
      ]
      include_context 'リクエスト送信', body: {num_tree: 'invalid'}
      it_behaves_like 'レスポンスが正常であること',
                      status: 400, body: {'errors' => errors}
      it_behaves_like 'DBにレコードが追加されていないこと', Analysis, default_params
    end
  end
end

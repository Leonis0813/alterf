# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  default_params = {num_data: 1000, num_tree: 100}

  shared_context 'リクエスト送信' do |body: default_params|
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(AnalysisJob).to receive(:perform_later).and_return(true)
        response = client.post('/analyses', body)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue nil
      end
    end
  end

  describe '正常系' do
    [default_params, default_params.merge(num_entry: 9)].each do |body|
      context "body: #{body}の場合" do
        include_context 'トランザクション作成'
        include_context 'リクエスト送信', body: body
        it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
        it_behaves_like 'DBにレコードが追加されていること', Analysis, body
      end
    end
  end

  describe '異常系' do
    required_keys = default_params.keys
    test_cases = [].tap do |tests|
      (required_keys.size - 1).times do |i|
        tests << required_keys.combination(i + 1).to_a
      end
    end.flatten(1)

    test_cases.each do |absent_keys|
      context "#{absent_keys.join(',')}がない場合" do
        selected_keys = required_keys - absent_keys
        errors = absent_keys.map {|key| {'error_code' => "absent_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.slice(*selected_keys)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと', Analysis, default_params
      end
    end

    accepted_keys = required_keys + [:num_entry]
    test_cases = [].tap do |tests|
      (required_keys.size - 1).times do |i|
        tests << required_keys.combination(i + 1).to_a
      end
    end.flatten(1)

    test_cases.each do |invalid_keys|
      context "#{invalid_keys.join(',')}が不正な場合" do
        invalid_params = invalid_keys.map {|key| [key, 'invalid'] }.to_h
        errors = invalid_keys.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context 'リクエスト送信', body: default_params.merge(invalid_params)
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと', Analysis, default_params
      end
    end
  end
end

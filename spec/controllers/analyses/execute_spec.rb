# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  default_params = {num_data: 1000, num_tree: 100}

  describe '正常系' do
    include_context 'トランザクション作成'

    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(AnalysisJob).to receive(:perform_later).and_return(true)
        @res = client.post('/analyses', default_params)
        @pbody = JSON.parse(@res.body) rescue nil
      end
    end

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスが空であること' do
      is_asserted_by { @pbody == {} }
    end
  end

  describe '異常系' do
    param_keys = default_params.keys
    test_cases = [].tap do |tests|
      (param_keys.size - 1).times {|i| tests << param_keys.combination(i + 1).to_a }
    end.flatten(1)

    test_cases.each do |error_keys|
      context "#{error_keys.join(',')}がない場合" do
        selected_keys = param_keys - error_keys
        error_codes = error_keys.map {|key| "absent_param_#{key}" }
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(AnalysisJob).to receive(:perform_later).and_return(true)
            @res = client.post('/analyses', default_params.slice(*selected_keys))
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it_behaves_like 'ステータスコードが正しいこと', '400'
        it_behaves_like 'エラーコードが正しいこと', error_codes
      end

      context "#{error_keys.join(',')}が不正な場合" do
        error_codes = error_keys.map {|key| "invalid_param_#{key}" }
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(AnalysisJob).to receive(:perform_later).and_return(true)
            params = default_params.dup
            error_keys.each {|key| params.merge!(key => 'invalid') }
            @res = client.post('/analyses', params)
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it_behaves_like 'ステータスコードが正しいこと', '400'
        it_behaves_like 'エラーコードが正しいこと', error_codes
      end
    end
  end
end

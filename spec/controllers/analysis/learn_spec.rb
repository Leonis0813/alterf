# coding: utf-8
require 'rails_helper'

describe AnalysisController, :type => :controller do
  default_params = {:num_data => 1000, :num_tree => 100, :num_feature => 10}

  describe '正常系' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(AnalysisJob).to receive(:perform_later).and_return(true)
        @res = client.post('/analysis/learn', default_params)
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
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(AnalysisJob).to receive(:perform_later).and_return(true)
            @res = client.post('/analysis/learn', default_params.slice(*selected_keys))
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it '400エラーが返ること' do
          is_asserted_by { @res.status == 400 }
        end
      end

      context "#{error_keys.join(',')}が不正な場合" do
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(AnalysisJob).to receive(:perform_later).and_return(true)
            params = default_params.dup
            error_keys.each {|key| params.merge!(key => 'invalid') }
            @res = client.post('/analysis/learn', params)
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it '400エラーが返ること' do
          is_asserted_by { @res.status == 400 }
        end
      end
    end
  end
end

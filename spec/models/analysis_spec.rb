# coding: utf-8
require 'rails_helper'

describe Analysis, :type => :model do
  shared_context 'Analysisオブジェクトを検証する' do |params|
    before(:all) do
      @analysis = Analysis.new(params)
      @analysis.validate
    end
  end

  shared_examples '検証結果が正しいこと' do |result|
    it_is_asserted_by { @analysis.errors.empty? == result }
  end

  describe '#validates' do
    describe '正常系' do
      include_context 'Analysisオブジェクトを検証する', {:num_data => 1, :num_tree => 1, :num_feature => 1, :state => 'processing'}
      it_behaves_like '検証結果が正しいこと', true
    end

    describe '異常系' do
      invalid_params = {
        :num_data => ['invalid', 1.0, 0],
        :num_tree => ['invalid', 1.0, 0],
        :num_feature => ['invalid', 1.0, 0],
        :state => ['invalid', 1.0, 0],
      }

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Analysisオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', false
        end
      end
    end
  end
end

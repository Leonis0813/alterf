# coding: utf-8

require 'rails_helper'

describe Evaluation, type: :model do
  shared_context 'Evaluationオブジェクトを検証する' do |params|
    before(:all) do
      @evaluation = Evaluation.new(params)
      @evaluation.validate
    end
  end

  shared_examples '検証結果が正しいこと' do |result|
    it_is_asserted_by { @evaluation.errors.empty? == result }
  end

  describe '#validates' do
    describe '正常系' do
      valid_params = {
        model: %w[model],
        state: %w[processing completed error],
      }

      test_cases = CommonHelper.generate_test_case(valid_params).select do |test_case|
        test_case.keys == valid_params.keys
      end

      test_cases.each do |params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Evaluationオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      invalid_params = {
        model: [1.0, 0, true, [], {}],
        state: ['invalid', 1.0, 0, true, [], {}],
      }

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Evaluationオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', false
        end
      end
    end
  end
end

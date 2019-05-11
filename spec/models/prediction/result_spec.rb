# coding: utf-8

require 'rails_helper'

describe Prediction::Result, type: :model do
  shared_context 'Prediction::Resultオブジェクトを検証する' do |params|
    before(:all) do
      @prediction_result = Prediction::Result.new(params)
      @prediction_result.validate
    end
  end

  shared_examples '検証結果が正しいこと' do |result|
    it_is_asserted_by { @prediction_result.errors.empty? == result }
  end

  describe '#validates' do
    describe '正常系' do
      include_context 'Prediction::Resultオブジェクトを検証する',
                      prediction_id: 1, number: 1
      it_behaves_like '検証結果が正しいこと', true
    end

    describe '異常系' do
      invalid_params = {
        number: ['invalid', 1.0, 0, true, [], {}],
      }

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "#{params.keys.join(',')}を指定した場合" do
          include_context 'Prediction::Resultオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', false
        end
      end
    end
  end
end

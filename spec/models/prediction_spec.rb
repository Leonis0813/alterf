# coding: utf-8

require 'rails_helper'

describe Prediction, type: :model do
  shared_context 'Predictionオブジェクトを検証する' do |params|
    before(:all) do
      @prediction = Prediction.new(params)
      @prediction.validate
    end
  end

  shared_examples '検証結果が正しいこと' do |result|
    it_is_asserted_by { @prediction.errors.empty? == result }
  end

  describe '#validates' do
    describe '正常系' do
      include_context 'Predictionオブジェクトを検証する',
                      model: 'model', test_data: 'test_data', state: 'processing'
      it_behaves_like '検証結果が正しいこと', true
    end

    describe '異常系' do
      invalid_params = {
        model: [1.0, 0, true, [], {}],
        test_data: [1.0, 0, true, [], {}],
        state: ['invalid', 1.0, 0, true, [], {}],
      }

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "フォームに#{params.keys.join(',')}を指定した場合" do
          include_context 'Predictionオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', false
        end
      end
    end
  end
end

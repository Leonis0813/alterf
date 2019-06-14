# coding: utf-8

require 'rails_helper'

describe Evaluation, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        evaluation_id: ['0' * 32],
        model: %w[model],
        state: %w[processing completed error],
      }

      test_cases = CommonHelper.generate_test_case(valid_attribute).select do |test_case|
        test_case.keys == valid_attribute.keys
      end

      test_cases.each do |attribute|
        context "フォームに#{attribute.keys.join(',')}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        evaluation_id: ['invalid', 'g' * 32, 1.0, 0, true, nil],
        model: [1.0, 0, true, nil],
        state: ['invalid', 1.0, 0, true, nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "フォームに#{attribute.keys.join(',')}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していること',
                          absent_keys: invalid_attribute.keys - attribute.keys,
                          invalid_keys: attribute.keys - %i[model]
        end
      end
    end
  end

  describe '#calculate_precision!' do
    describe '正常系' do
      data = [
        {numbers: [], ground_truth: 1},
        {numbers: [1], ground_truth: 1},
        {numbers: [1, 3], ground_truth: 1},
        {numbers: [2, 4], ground_truth: 1},
      ]

      before(:all) do
        attribute = {evaluation_id: '0' * 32, model: 'model', state: 'completed'}
        @evaluation = Evaluation.create!(attribute)

        data.each do |datum|
          evaluation_datum = @evaluation.data.create!(
            race_name: 'race_name',
            race_url: 'http://example.com',
            ground_truth: datum[:ground_truth],
          )
          datum[:numbers].each do |number|
            evaluation_datum.prediction_results.create!(number: number)
          end
        end

        @evaluation.calculate_precision!
      end

      it '精度が正しいこと' do
        is_asserted_by { @evaluation.precision == 0.5 }
      end
    end
  end
end

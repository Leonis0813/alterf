# coding: utf-8

require 'rails_helper'

describe Evaluation, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        evaluation_id: ['0' * 32],
        model: %w[model],
        data_source: %w[file remote text] + [nil],
        state: %w[processing completed error],
        precision: [0, 1, nil],
        recall: [0, 1, nil],
        f_measure: [0, 1, nil],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        evaluation_id: ['invalid', 'g' * 32, nil],
        data_source: %w[invalid],
        state: ['invalid', nil],
        precision: [-0.1, 1.1],
        recall: [-0.1, 1.1],
        f_measure: [-0.1, 1.1],
      }

      it_behaves_like '必須パラメーターがない場合のテスト', %i[evaluation_id state]
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end

  describe '#calculate!' do
    describe '正常系' do
      data = [
        {wons: [], ground_truth: 1},
        {wons: [1], ground_truth: 1},
        {wons: [1, 3], ground_truth: 1},
        {wons: [2, 4], ground_truth: 1},
      ]

      include_context 'トランザクション作成'
      before(:all) do
        attribute = {evaluation_id: '0' * 32, model: 'model', state: 'completed'}
        @evaluation = Evaluation.create!(attribute)

        data.each do |datum|
          evaluation_datum = @evaluation.data.create!(
            race_id: '1' * 8,
            race_name: 'race_name',
            race_url: 'http://example.com',
            ground_truth: datum[:ground_truth],
          )
          (1..4).each do |number|
            attribute = {number: number, won: datum[:wons].include?(number)}
            evaluation_datum.prediction_results.create!(attribute)
          end
        end

        @evaluation.calculate!
      end

      it '適合率が正しいこと' do
        is_asserted_by { @evaluation.precision == 0.4 }
      end

      it '再現率が正しいこと' do
        is_asserted_by { @evaluation.recall == 0.5 }
      end

      it 'F値が正しいこと' do
        is_asserted_by { @evaluation.f_measure.round(3) == 0.444 }
      end
    end
  end
end

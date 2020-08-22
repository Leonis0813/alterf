# coding: utf-8

require 'rails_helper'

describe Evaluation, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        evaluation_id: ['0' * 32],
        num_data: [20],
        state: %w[waiting processing completed error],
        precision: [0, 1, nil],
        recall: [0, 1, nil],
        f_measure: [0, 1, nil],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:evaluation, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end

      [
        [{data_source: 'random', num_data: nil}, 100],
        [{data_source: 'random', num_data: 10}, 10],
        [{data_source: 'remote', num_data: 1}, 20],
      ].each do |attribute, expected_num_data|
        context "#{attribute}を指定した場合" do
          before(:all) do
            @object = Evaluation.new(build(:evaluation).attributes.merge(attribute))
          end

          it_behaves_like 'バリデーションエラーにならないこと'

          it "num_dataに#{expected_num_data}が設定されていること" do
            is_asserted_by { @object.num_data == expected_num_data }
          end
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        evaluation_id: ['invalid', 'g' * 32],
        num_data: [0],
        state: ['invalid'],
        precision: [-0.1, 1.1],
        recall: [-0.1, 1.1],
        f_measure: [-0.1, 1.1],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:evaluation, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      [19, 21].each do |num_data|
        context "data_sourceがrandomの時に#{num_data}を指定した場合" do
          expected_error = {num_data: 'invalid_parameter'}
          before(:all) do
            @object = build(:evaluation, num_data: num_data)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end

  describe '#fetch_data!' do
    describe '正常系' do
      context 'datasourceがrandomの場合' do
        include_context 'トランザクション作成'
        before(:all) do
          create(:race)
          create(:feature, won: true)
          @evaluation = create(:evaluation, data_source: 'random', num_data: 1)
          @evaluation.update!(analysis: create(:analysis, num_entry: 1))
          @evaluation.fetch_data!
        end

        after(:all) do
          Denebola::Race.destroy_all
          Denebola::Feature.destroy_all
        end

        it '取得したレースIDが正しいこと' do
          is_asserted_by { @evaluation.data.size == 1 }
          is_asserted_by { @evaluation.data.first.race_id == '1234' }
        end
      end

      context 'datasourceがremoteの場合' do
        include_context 'トランザクション作成'
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            race = Denebola::Race.new(race_name: 'test')
            feature = Denebola::Feature.new(race_id: '1234', won: true, number: 1)
            allow_any_instance_of(NetkeibaClient).to(
              receive(:http_get_race_top).and_return(['1234']),
            )
            allow(Denebola::Race).to(receive(:find_by).and_return(race))
            allow(Denebola::Feature).to(receive(:find_by).and_return(feature))
            @evaluation = create(:evaluation, data_source: 'remote', num_data: 20)
            @evaluation.fetch_data!
          end
        end

        after(:all) { Denebola::Race.destroy_all }

        it '取得したレースIDが正しいこと' do
          is_asserted_by { @evaluation.data.size == 1 }
          is_asserted_by { @evaluation.data.first.race_id == '1234' }
        end
      end
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

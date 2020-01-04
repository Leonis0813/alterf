# coding: utf-8

require 'rails_helper'

describe Evaluation, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        evaluation_id: ['0' * 32],
        model: %w[model],
        data_source: %w[file random remote text],
        num_data: [20],
        state: %w[processing completed error],
        precision: [0, 1, nil],
        recall: [0, 1, nil],
        f_measure: [0, 1, nil],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute

      [
        [{data_source: 'random', num_data: nil}, 100],
        [{data_source: 'random', num_data: 10}, 10],
        [{data_source: 'remote', num_data: 1}, 20],
      ].each do |attribute, expected_num_data|
        context "#{attribute}を指定した場合" do
          before(:all) do
            @evaluation = Evaluation.new(build(:evaluation).attributes.merge(attribute))
            @evaluation.validate
          end

          it 'エラーにならないこと' do
            is_asserted_by { @evaluation.errors.empty? }
          end

          it "num_dataに#{expected_num_data}が設定されていること" do
            is_asserted_by { @evaluation.num_data == expected_num_data }
          end
        end
      end
    end

    describe '異常系' do
      base_invalid_attribute = {
        evaluation_id: ['invalid', 'g' * 32],
        data_source: %w[invalid],
        num_data: [0],
        state: ['invalid'],
        precision: [-0.1, 1.1],
        recall: [-0.1, 1.1],
        f_measure: [-0.1, 1.1],
      }

      absent_keys = %i[evaluation_id model state]
      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', base_invalid_attribute

      [19, 21].each do |num_data|
        context "data_sourceがrandomの時に#{num_data}を指定した場合" do
          before(:all) do
            @evaluation = build(:evaluation, num_data: num_data)
            @evaluation.validate
          end

          it 'invalidエラーになること' do
            is_asserted_by { @evaluation.errors.present? }
            is_asserted_by do
              @evaluation.errors.messages[:num_data].include?('invalid')
            end
          end
        end
      end
    end
  end

  describe '#fetch_data!' do
    describe '正常系' do
      context 'datasourceがrandomの場合' do
        include_context 'トランザクション作成'
        before(:all) do
          attribute = {
            direction: '右',
            distance: 1,
            place: '東京',
            race_id: '1234',
            race_name: 'test',
            round: 1,
            start_time: Time.zone.today,
            track: '芝',
            weather: '晴',
          }
          RSpec::Mocks.with_temporary_scope do
            race = Denebola::Race.create!(attribute)
            feature = Denebola::Feature.new(race_id: 'test', won: true, number: 1)
            allow(Denebola::Race).to(receive(:order).and_return([race]))
            allow(Denebola::Race).to(receive(:find).and_return(race))
            allow(Denebola::Feature).to(receive(:find_by).and_return(feature))
            allow(Denebola::Feature).to(receive(:where).and_return([feature]))
            @evaluation = create(:evaluation, data_source: 'random', num_data: 1)
            @evaluation.update!(analysis: create(:analysis, num_entry: 1))
            @evaluation.fetch_data!
          end
        end

        after(:all) { Denebola::Race.destroy_all }

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

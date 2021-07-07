# coding: utf-8

require 'rails_helper'

describe Evaluation::Race::TestDatum, type: :model do
  shared_context '評価テストデータ情報を作成する' do |order: '1'|
    before do
      race = create(:race)
      create(:entry, {race_id: race.id, order: order})
      @expected_feature = create(:feature, {race_id: race.race_id, number: 1})
      evaluation = create(:evaluation)
      attribute = {evaluation_id: evaluation.id, race_id: race.race_id}
      evaluation_race = create(:evaluation_race, attribute)
      @test_datum = evaluation_race.test_data.create!(number: 1)
    end
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        number: %w[1],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:evaluation_race_test_datum, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      required_keys = %i[number]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}が指定されていない場合" do
          expected_error = absent_keys.map {|key| [key, 'absent_parameter'] }.to_h

          before(:all) do
            attribute = absent_keys.map {|key| [key, nil] }.to_h
            @object = build(:evaluation_race_test_datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        number: ['invalid', 0, 1.0],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:evaluation_race_test_datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end

  describe '#order' do
    [
      ['1', 1],
      ['string', 'string'],
    ].each do |order, expected|
      context "orderが#{order}の場合" do
        include_context 'トランザクション作成'
        include_context '評価テストデータ情報を作成する', order: order
        it '戻り値が正しいこと' do
          is_asserted_by { @test_datum.order == expected }
        end
      end
    end
  end

  describe '#feature' do
    include_context 'トランザクション作成'
    include_context '評価テストデータ情報を作成する'
    before { @feature = @test_datum.feature }

    %w[
      age
      blank
      burden_weight
      direction
      distance
      distance_diff
      entry_times
      grade
      horse_average_prize_money
      jockey_average_prize_money
      jockey_win_rate
      jockey_win_rate_last_four_races
      last_race_order
      month
      number
      place
      rate_within_third
      round
      running_style
      second_last_race_order
      sex
      track
      weather
      weight
      weight_diff
      weight_per
      win_times
    ].each do |feature_name|
      it "#{feature_name}が取得できていること" do
        is_asserted_by { @feature[feature_name] == @expected_feature[feature_name] }
      end
    end
  end
end

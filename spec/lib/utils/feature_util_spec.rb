# coding: utf-8

require 'rails_helper'

describe FeatureUtil do
  feature = {
    direction: '左',
    distance: 1800,
    grade: 'G1',
    month: 5,
    place: '中京',
    round: 11,
    track: '芝',
    weather: '晴',
    entries: [
      {
        age: 3,
        average_prize_money: 100,
        blank: 7,
        burden_weight: 56,
        distance_diff: 0.123,
        entry_times: 3,
        last_race_order: 10,
        number: 5,
        rate_within_third: 0.33,
        running_style: '逃げ',
        second_last_race_order: 2,
        sex: '牝',
        weight: 402,
        weight_diff: -8,
        weight_per: 0.139303,
        win_times: 1,
        won: true,
      },
    ],
  }

  describe '.create_feature' do
    horse_id = '2017103903'
    race_id = '201809030811'
    expected = feature.except(:entries).merge(
      entries: feature[:entries].map(&:values),
    ).stringify_keys

    describe '正常系' do
      before(:all) do
        feature[:entries].map do |entry|
          attribute = feature.except(:entries).merge(entry).merge(
            horse_id: horse_id,
            race_id: race_id,
          )
          Denebola::Feature.create!(attribute)
        end
        @feature = FeatureUtil.create_feature(race_id)
      end

      after(:all) { Denebola::Feature.destroy_all }

      it '作成された素性が正しいこと' do
        is_asserted_by { @feature == expected }
      end
    end
  end
end

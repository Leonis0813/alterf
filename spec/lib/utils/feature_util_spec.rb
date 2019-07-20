# coding: utf-8

require 'rails_helper'

describe FeatureUtil do
  race = {
    direction: '左',
    distance: 1800,
    grade: 'G1',
    month: 5,
    place: '中京',
    race_name: 'テスト',
    round: 11,
    track: '芝',
    weather: '晴',
    entries: [
      {
        age: 3,
        burden_weight: 56,
        order: 2,
        number: 5,
        sex: '牝',
        weight: 402,
        weight_diff: -8,
        weight_per: 0.139303,
        horse_link: '/horse/2013106099',
      },
    ],
  }
  horse = {
    running_style: '逃げ',
    results: [
      {
        race_id: '201809030811',
        date: Date.parse('2018/12/23'),
        order: 3,
        distance: 1800,
        prize_money: 45000000,
      },
      {
        race_id: '201809030810',
        date: Date.parse('2018/12/16'),
        order: 5,
        distance: 1400,
        prize_money: 0,
      },
    ],
  }
  expected = race.except(:entries).merge(
    entries: [
      [
        race[:entries].first[:age],
        (45000000 + 0) / 2.0,
        (horse[:results].first[:date] - horse[:results].second[:date]).to_i,
        race[:entries].first[:burden_weight],
        100.0,
        horse[:results].size,
        horse[:results].second[:order],
        race[:entries].first[:number],
        0.5,
        horse[:running_style],
        0,
        race[:entries].first[:sex],
        race[:entries].first[:weight],
        race[:entries].first[:weight_diff],
        race[:entries].first[:weight_per],
        0,
        race[:entries].first[:order],
      ],
    ],
  )

  describe '.create_feature' do
    describe '正常系' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow_any_instance_of(NetkeibaClient).to(
            receive(:http_get_race).and_return(race),
          )
          allow_any_instance_of(NetkeibaClient).to(
            receive(:http_get_horse).and_return(horse),
          )
          @feature = FeatureUtil.create_feature('/race/201809030811')
        end
      end

      it '作成された素性が正しいこと' do
        is_asserted_by { @feature == expected }
      end
    end
  end
end

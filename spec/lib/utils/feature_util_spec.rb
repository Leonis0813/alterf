# coding: utf-8

require 'rails_helper'

describe FeatureUtil do
  describe '.create_feature_from_denebola' do
    dirs = %w[spec fixtures lib utils feature_util create_feature_from_denebola]
    file_path = Rails.root.join(dirs.join('/'), 'feature.yml')
    feature = YAML.load_file(file_path).with_indifferent_access
    entries = feature[:entries].map(&:values)
    expected = feature.except(:entries).merge(entries: entries).stringify_keys
    race_id = '201809030811'

    describe '正常系' do
      before(:all) do
        feature[:entries].map do |entry|
          attribute = feature.except(:entries).merge(entry).merge(
            horse_id: '2017103903',
            race_id: race_id,
          )
          Denebola::Feature.create!(attribute)
        end
        @feature = FeatureUtil.create_feature_from_denebola(race_id)
      end

      after(:all) { Denebola::Feature.destroy_all }

      it '作成された素性が正しいこと' do
        is_asserted_by { @feature == expected }
      end
    end
  end

  describe '.create_feature_from_netkeiba' do
    dirs =
      %w[spec fixtures lib utils feature_util create_feature_from_netkeiba].join('/')
    race = YAML.load_file(Rails.root.join(dirs, 'race.yml')).with_indifferent_access
    horse = YAML.load_file(Rails.root.join(dirs, 'horse.yml')).with_indifferent_access
    jockey = YAML.load_file(Rails.root.join(dirs, 'jockey.yml')).with_indifferent_access

    expected = race.except(:entries).merge(
      entries: [
        [
          race[:entries].first[:age],
          (horse[:results].first[:date] - horse[:results].second[:date]).to_i,
          race[:entries].first[:burden_weight],
          100.0,
          horse[:results].size,
          (45000000 + 0) / 2.0,
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
          false,
          (45000000 + 0) / 2.0,
          0,
          0,
        ],
      ],
    )

    describe '正常系' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow_any_instance_of(NetkeibaClient).to(
            receive(:http_get_race).and_return(race),
          )
          allow_any_instance_of(NetkeibaClient).to(
            receive(:http_get_horse).and_return(horse),
          )
          allow_any_instance_of(NetkeibaClient).to(
            receive(:http_get_jockey).and_return(jockey),
          )
          @feature = FeatureUtil.create_feature_from_netkeiba('/race/201809030811')
        end
      end

      it '作成された素性が正しいこと' do
        is_asserted_by { @feature == expected }
      end
    end
  end
end

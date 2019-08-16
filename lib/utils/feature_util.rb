require_relative '../clients/netkeiba_client'

class FeatureUtil
  class << self
    def create_feature_from_netkeiba(race_path)
      race_id = race_path.match(%r{/race/(\d+)})[1]
      client = NetkeibaClient.new
      race = client.http_get_race(race_path)

      feature = race.slice(*Settings.prediction.feature.races.map(&:to_sym))
      feature[:race_name] = race[:race_name]
      feature[:entries] = []

      race[:entries].each do |entry|
        horse_feature = client.http_get_horse(entry[:horse_link])
        entry.delete(:horse_link)

        entry[:running_style] = horse_feature[:running_style]

        target_race_index = race_index(horse_feature[:results], race_id)
        target_horse_results = horse_feature[:results][target_race_index..-1]

        jockey_feature = client.http_get_jockey(entry[:jockey_link])
        entry.delete(:jockey_link)

        target_race_index = race_index(jockey_feature[:results], race_id)
        target_jockey_results = jockey_feature[:results][target_race_index..-1]

        entry.merge!(extra_feature(target_horse_results, target_jockey_results, feature))
        entry.merge!(won: entry[:order] == 1)

        entry_attributes = Settings.prediction.feature.horses +
                           Settings.prediction.feature.jockeys
        entry_features = entry_attributes.map(&:to_sym).map {|name| entry[name] }

        feature[:entries] << entry_features
      end

      feature
    end

    def create_feature_from_denebola(race_id)
      features = Denebola::Feature.where(race_id: race_id)

      race_feature = features.first.slice(*Settings.prediction.feature.races)

      entry_attributes = Settings.prediction.feature.horses +
                         Settings.prediction.feature.jockeys

      entry_features = features.map {|feature| feature.slice(*entry_attributes) }

      race_feature.tap do |feature|
        feature['entries'] = []

        entry_features.each do |entry_feature|
          feature['entries'] << entry_attributes.map {|name| entry_feature[name] }
        end
      end
    end

    private

    def extra_feature(horse_results, jockey_results, race)
      sum_prize_money = horse_results.map {|result| result[:prize_money] }.inject(:+)
      sum_distance = horse_results.map {|result| result[:distance] }.inject(:+)
      average_distance = sum_distance / horse_results.size.to_f
      times_within_third = horse_results.select {|result| result[:order] <= 3 }.size

      {
        horse_average_prize_money: sum_prize_money / horse_results.size.to_f,
        blank: (horse_results.first[:date] - horse_results.second[:date]).to_i,
        distance_diff: (race[:distance] - average_distance).abs / horse_results.size,
        entry_times: horse_results.size,
        last_race_order: horse_results.second ? horse_results.second[:order] : 0,
        rate_within_third: times_within_third / horse_results.size.to_f,
        second_last_race_order: horse_results.third ? horse_results.third[:order] : 0,
        win_times: horse_results.select {|result| result[:order] == 1 }.size,
      }
    end

    def race_index(results, race_id)
      results.index {|result| result[:race_id] == race_id } || 0
    end
  end
end

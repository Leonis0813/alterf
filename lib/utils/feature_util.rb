require_relative '../clients/netkeiba_client'

class FeatureUtil
  class << self
    def create_feature_from_netkeiba(race_path)
      race_id = race_path.match(%r{/race/(\d+)})[1]
      client = NetkeibaClient.new
      race = client.http_get_race(race_path)

      feature = race.slice(*Settings.prediction.feature.races.map(&:to_sym))
      feature[:entries] = []

      race[:entries].each do |entry|
        horse_feature = client.http_get_horse(entry[:horse_link])
        entry.delete(:horse_link)

        entry[:running_style] = horse_feature[:running_style]

        target_horse_results = target_results(horse_feature[:results], race_id)

        jockey_feature = client.http_get_jockey(entry[:jockey_link])
        entry.delete(:jockey_link)

        target_jockey_results = target_results(jockey_feature[:results], race_id)

        entry.merge!(extra_horse_feature(target_horse_results, feature))
        entry.merge!(extra_jockey_feature(target_jockey_results))
        entry_features = (entry_attributes.map(&:to_sym) - [:won]).map do |name|
          entry[name]
        end

        feature[:entries] << entry_features
      end

      feature
    end

    def create_feature_from_denebola(race_id)
      features = Denebola::Feature.where(race_id: race_id)

      race_feature = features.first.slice(*Settings.prediction.feature.races)
      entry_features = features.map {|feature| feature.slice(*entry_attributes) }

      race_feature.tap do |feature|
        feature['entries'] = []

        entry_features.each do |entry_feature|
          feature['entries'] << entry_attributes.map {|name| entry_feature[name] }
        end
      end
    end

    private

    def extra_horse_feature(results, race)
      sum_prize_money = results.map {|result| result[:prize_money] }.inject(:+)
      sum_distance = results.map {|result| result[:distance] }.inject(:+)
      average_distance = sum_distance / results.size.to_f
      times_within_third = results.count {|result| result[:order].between?(1, 3) }

      {
        blank: (results.first[:date] - results.second[:date]).to_i,
        distance_diff: (race[:distance] - average_distance).abs / results.size,
        entry_times: results.size,
        horse_average_prize_money: sum_prize_money / results.size.to_f,
        last_race_order: results.second ? results.second[:order] : 0,
        rate_within_third: times_within_third / results.size.to_f,
        second_last_race_order: results.third ? results.third[:order] : 0,
        win_times: results.count {|result| result[:order] == 1 },
      }
    end

    def extra_jockey_feature(results)
      sum_prize_money = results.map {|result| result[:prize_money] }.inject(:+)
      win_times_last_four_races = results[0, 4].count {|result| result[:order] == 1 }
      entry_times = results.size.to_f

      {
        jockey_average_prize_money: sum_prize_money / entry_times,
        jockey_win_rate: results.count {|result| result[:order] == 1 } / entry_times,
        jockey_win_rate_last_four_races: win_times_last_four_races / entry_times,
      }
    end

    def target_results(results, race_id)
      target_race_index = results.index {|result| result[:race_id] == race_id } || 0
      results[target_race_index..-1]
    end

    def entry_attributes
      Settings.prediction.feature.horses + Settings.prediction.feature.jockeys
    end
  end
end

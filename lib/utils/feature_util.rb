require_relative '../clients/netkeiba_client'

class FeatureUtil
  def self.create_feature(race_path)
    client = NetkeibaClient.new
    race = client.http_get_race(race_path)

    feature = race.slice(*Settings.prediction.feature.races.map(&:to_sym))
    feature[:entries] = []

    race[:entries].each do |entry|
      horse_feature = client.http_get_horse(entry[:horse_link])
      entry.delete(:horse_link)

      entry[:running_style] = horse_feature[:running_style]

      race_id = race_path.match(%r{/race/(\d+)})[1]
      target_race_index = horse_feature[:results].index do |result|
        result[:race_id] == race_id
      end
      target_results = horse_feature[:results][target_race_index..-1]
      entry.merge!(extra_feature(target_results, feature))

      feature[:entries] << Settings.prediction.feature.horses.map(&:to_sym).map do |name|
        entry[name]
      end
    end

    feature
  end

  def self.extra_feature(results, race)
    sum_prize_money = results.map {|result| result[:prize_money] }.inject(:+)
    sum_distance = results.map {|result| result[:distance] }.inject(:+)
    average_distance = sum_distance / results.size.to_f
    times_within_third = results.select {|result| result[:order] <= 3 }.size

    {
      average_prize_money: sum_prize_money / results.size.to_f,
      blank: (results.first[:date] - results.second[:date]).to_i,
      distance_diff: (race[:distance] - average_distance).abs / results.size,
      entry_times: results.size,
      last_race_order: results.second ? results.second[:order] : 0,
      rate_within_third: times_within_third / results.size.to_f,
      second_last_race_order: results.third ? results.third[:order] : 0,
      win_times: results.select {|result| result[:order] == 1 }.size,
    }
  end
end

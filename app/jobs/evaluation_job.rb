require_relative '../../lib/clients/netkeiba_client'

class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)

    client = NetkeibaClient.new

    client.http_get_race_top.each do |race_id|
      race = client.http_get_race("#{Settings.netkeiba.base_url}/race/#{race_id}")
      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        YAML.dump(race.stringify_keys, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"

      result_file = File.join(data_dir, 'prediction.yml')
      FileUtils.mv(result_file, "#{data_dir}/#{race_id}.yml") if File.exist?(result_file)
    end

    evaluation.update!(state: 'completed')

    FileUtils.rm_f("#{data_dir}/#{Settings.prediction.tmp_file_name}")
    FileUtils.rm_f("#{data_dir}/#{evaluation.model}")
    EvaluationMailer.finished(evaluation, true).deliver_now
    FileUtils.rm_rf(data_dir)
  end

  private

  def create_feature(race_url)
    client = NetkeibaClient.new
    race = client.http_get_race(race_url)

    race_features = %i[direction distance grade month place round track weather]
    feature = race.slice(*race_features)
    feature[:entries] = []

    race[:entries].each do |entry|
      horse_url = "https://db.netkeiba.com#{entry[:horse_link]}"
      horse_feature = client.http_get_horse(horse_url)
      entry.delete(:horse_link)

      entry[:running_style] = horse_feature[:running_style]

      race_id = race_url.match(%r{/race/(\d+)})[1]
      target_race_index = horse_feature[:results].index {|result| result[:race_id] == race_id }
      target_results = horse_feature[:results][target_race_index..-1]

      sum_prize_money = target_results.map {|result| result[:prize_money] }.inject(:+)
      entry[:average_prize_money] = sum_prize_money / target_results.size.to_f
      entry[:blank] = (target_results.first[:date] - target_results.second[:date]).to_i

      sum_distance = target_results.map {|result| result[:distance] }.inject(:+)
      average_distance = sum_distance / target_results.size.to_f
      entry[:distance_diff] = (feature[:distance] - average_distance).abs / target_results.size
      entry[:entry_times] = target_results.size

      last_race = target_results.second
      entry[:last_race_order] = last_race ? last_race[:order] : 0

      times_within_third = target_results.select {|result| result[:order] <= 3 }.size
      entry[:rate_within_third] = times_within_third / target_results.size.to_f

      second_last_race = target_results.third
      entry[:second_last_race_order] = second_last_race ? second_last_race[:order] : 0
      entry[:win_times] = target_results.select {|result| result[:order] == 1 }.size

      feature[:entries] << %i[age average_prize_money blank burden_weight distance_diff
        entry_times last_race_order number rate_within_third running_style
        second_last_race_order sex weight weight_diff weight_per win_times].map do |name|
        entry[name]
      end
    end

    feature
  end
end

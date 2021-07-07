module Denebola
  class Feature < Denebola::Base
    NAMES = %w[
      order
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
    ].freeze
  end
end

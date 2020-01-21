# -*- coding: utf-8 -*-

FactoryBot.define do
  factory :feature, class: 'Denebola::Feature' do
    age { 4 }
    blank { 7 }
    burden_weight { 56.0 }
    direction { '右' }
    distance { 1800 }
    distance_diff { 0.1 }
    entry_times { 3 }
    horse_average_prize_money { 1000000 }
    jockey_average_prize_money { 1000000 }
    jockey_win_rate { 0.5 }
    jockey_win_rate_last_four_races { 0.75 }
    horse_id { '5678' }
    last_race_order { 3 }
    month { 5 }
    number { 10 }
    place { '東京' }
    race_id { '1234' }
    rate_within_third { 0.5 }
    round { 10 }
    running_style { '先行' }
    second_last_race_order { 5 }
    sex { '牝' }
    track { '芝' }
    weather { '晴' }
    weight { 468.0 }
    weight_diff { -4 }
    weight_per { 0.2 }
    win_times { 1 }
  end
end

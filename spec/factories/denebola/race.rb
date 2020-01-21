# -*- coding: utf-8 -*-

FactoryBot.define do
  factory :race, class: 'Denebola::Race' do
    direction { '右' }
    distance { 1800 }
    place { '東京' }
    race_id { '1234' }
    race_name { 'test' }
    round { 10 }
    start_time { '2000-01-01 00:00:00' }
    track { '芝' }
    weather { '晴' }
  end
end

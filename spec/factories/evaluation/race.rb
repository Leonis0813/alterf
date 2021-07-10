FactoryBot.define do
  factory :evaluation_race, class: 'Evaluation::Race' do
    race_id { '1' * 8 }
    race_name { 'test' }
    race_url { 'https://example.com' }
    ground_truth { 1 }
  end
end

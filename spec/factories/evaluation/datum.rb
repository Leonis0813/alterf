FactoryBot.define do
  factory :datum, class: 'Evaluation::Datum' do
    race_name { 'test' }
    race_url { 'https://example.com' }
    ground_truth { 1 }
  end
end

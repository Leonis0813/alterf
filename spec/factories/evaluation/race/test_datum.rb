FactoryBot.define do
  factory :evaluation_race_test_datum, class: 'Evaluation::Race::TestDatum' do
    number { 1 }
    prediction_result { true }
  end
end

FactoryBot.define do
  factory :result, class: 'Prediction::Result' do
    number { 1 }
    won { false }
  end
end

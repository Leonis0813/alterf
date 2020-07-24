FactoryBot.define do
  factory :importance, class: 'Analysis::Result::Importance' do
    feature_name { 'test' }
    value { 0.01 }
  end
end

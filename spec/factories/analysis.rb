FactoryBot.define do
  factory :analysis do
    analysis_id { '0' * 32 }
    num_data { 10000 }
    num_tree { 100 }
    num_feature { 20 }
    state { 'waiting' }
    result { build(:analysis_result) }
  end
end

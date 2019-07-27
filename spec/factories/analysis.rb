FactoryBot.define do
  factory :analysis do
    num_data { 10000 }
    num_tree { 100 }
    num_feature { 20 }
    state { 'processing' }
  end
end

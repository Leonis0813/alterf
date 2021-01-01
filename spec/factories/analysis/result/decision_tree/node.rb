FactoryBot.define do
  factory :node, class: 'Analysis::Result::DecisionTree::Node' do
    node_id { 0 }
    node_type { 'split' }
    group { 'less' }
    feature_name { 'test' }
    threshold { 0.1 }
  end
end

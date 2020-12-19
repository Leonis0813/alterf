FactoryBot.define do
  factory :decision_tree, class: 'Analysis::Result::DecisionTree' do
    tree_id { 0 }
    nodes { [build(:node)] }
  end
end

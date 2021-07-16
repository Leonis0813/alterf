FactoryBot.define do
  factory :decision_tree, class: 'Analysis::Result::DecisionTree' do
    decision_tree_id { '000000' }
    nodes { [build(:node)] }
  end
end

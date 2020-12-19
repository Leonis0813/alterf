FactoryBot.define do
  factory :analysis_result, class: 'Analysis::Result' do
    importances { [build(:importance)] }
    decision_trees { [build(:decision_tree)] }
  end
end

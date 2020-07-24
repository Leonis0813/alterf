FactoryBot.define do
  factory :analysis_result, class: 'Analysis::Result' do
    importances { [build(:importance)] }
  end
end

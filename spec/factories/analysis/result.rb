FactoryBot.define do
  factory :analysis_result, class: 'Analysis::Result' do
    importances { [] }
  end
end

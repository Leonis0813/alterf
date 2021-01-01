FactoryBot.define do
  factory :analysis_parameter, class: 'Analysis::Parameter' do
    min_samples_leaf { 1 }
    min_samples_split { 2 }
    num_tree { 100 }
  end
end

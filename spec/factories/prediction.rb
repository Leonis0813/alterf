FactoryBot.define do
  factory :prediction do
    model { 'model.rf' }
    test_data { 'test_data.yml' }
    state { 'processing' }
  end
end

FactoryBot.define do
  factory :evaluation do
    evaluation_id { '0' * 32 }
    model { 'model.rf' }
    data_source { 'remote' }
    state { 'processing' }
    precision { 0.5 }
    recall { 0.5 }
    f_measure { 0.5 }
  end
end

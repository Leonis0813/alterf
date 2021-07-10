# -*- coding: utf-8 -*-

FactoryBot.define do
  factory :entry, class: 'Denebola::Entry' do
    age { 4 }
    burden_weight { 56.0 }
    number { 1 }
    order { '1' }
    prize_money { 100000 }
    sex { '牝' }
  end
end

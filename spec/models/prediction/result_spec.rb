# coding: utf-8

require 'rails_helper'

describe Prediction::Result, type: :model do
  describe '#validates' do
    describe '正常系' do
      include_context 'オブジェクトを検証する',
                      predictable_id: 1, predictable_type: 'Prediction', number: 1
      it_behaves_like 'エラーが発生していないこと'
    end

    describe '異常系' do
      invalid_attribute = {
        number: ['invalid', 1.0, 0, true, nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していること', invalid_keys: [:number]
        end
      end

      context 'numberを指定しない場合' do
        include_context 'オブジェクトを検証する', {}
        it_behaves_like 'エラーが発生していること', absent_keys: [:number]
      end
    end
  end
end

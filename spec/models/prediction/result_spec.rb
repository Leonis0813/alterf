# coding: utf-8

require 'rails_helper'

describe Prediction::Result, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        number: [1],
        won: [true, false],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:result, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      context 'numberが指定されていない場合' do
        expected_error = {number: 'absent_parameter'}

        before(:all) do
          @object = build(:result, number: nil)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end

      invalid_attribute = {
        number: [0],
        won: [nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:result, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end
end

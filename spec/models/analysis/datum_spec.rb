# coding: utf-8

require 'rails_helper'

describe Analysis::Datum, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        race_id: ['2'],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) do
            @object = build(:analysis_datum, attribute.merge(analysis_id: 1))
          end

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        race_id: [nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'absent_parameter'] }.to_h

          before(:all) do
            @object = build(:analysis_datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end

  describe '#copy_attributes' do
    before(:all) do
      datum = build(:analysis_datum)
      @attribute = datum.copy_attributes
    end

    it '属性を正しく返していること' do
      is_asserted_by { @attribute == {'race_id' => '1'} }
    end
  end
end

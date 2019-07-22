# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        num_data: [1],
        num_tree: [1],
        num_feature: [1, nil],
        state: %w[processing completed error],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "フォームに#{attribute}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        num_data: ['invalid', 1.0, 0, true, nil],
        num_tree: ['invalid', 1.0, 0, true, nil],
        num_feature: ['invalid', 1.0, 0, true],
        state: ['invalid', nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "フォームに#{attribute}を指定した場合" do
          absent = invalid_attribute.keys - attribute.keys - %i[num_feature]
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していること',
                          absent_keys: absent,
                          invalid_keys: attribute.keys
        end
      end
    end
  end
end

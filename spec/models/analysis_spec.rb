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

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        num_data: [1.0, 0, nil],
        num_tree: [1.0, 0, nil],
        num_feature: [1.0, 0],
        state: ['invalid', nil],
      }
      absent_keys = invalid_attribute.keys - %i[num_feature]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end

# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        analysis_id: ['0' * 32],
        num_data: [1],
        num_tree: [1],
        num_feature: [1, nil],
        num_entry: [1, nil],
        state: %w[processing completed error],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        analysis_id: ['invalid', 'g' * 32, nil],
        num_data: [0],
        num_tree: [0],
        num_feature: [0],
        num_entry: [0],
        state: %w[invalid],
      }
      absent_keys = invalid_attribute.keys - %i[num_feature num_entry]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end

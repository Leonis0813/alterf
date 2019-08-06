# coding: utf-8

require 'rails_helper'

describe Prediction::Result, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        number: [1],
        won: [true, false],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        number: [0],
        won: [nil],
      }

      it_behaves_like '必須パラメーターがない場合のテスト', %i[number]
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end

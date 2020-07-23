# coding: utf-8

require 'rails_helper'

describe Analysis::Result::Importance, type: :model do
  describe '#validates' do
    describe '正常系' do
      include_context 'トランザクション作成'
      before(:all) do
        create(:importance, analysis_result_id: 2)
        @importance = build(:importance, analysis_result_id: 1)
      end

      it 'バリデーションエラーにならないこと' do
        is_asserted_by { @importance.valid? }
      end
    end

    describe '異常系' do
      include_context 'トランザクション作成'
      before(:all) do
        create(:importance, analysis_result_id: 1)
        @importance = build(:importance, analysis_result_id: 1)
      end

      it 'バリデーションエラーになること' do
        is_asserted_by { @importance.invalid? }
      end
    end
  end
end

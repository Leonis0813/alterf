# coding: utf-8

require 'rails_helper'

describe Analysis::Result::Importance, type: :model do
  describe '#validates' do
    describe '正常系' do
      include_context 'トランザクション作成'
      before(:all) do
        create(:importance, analysis_result_id: 2)
        @object = build(:importance, analysis_result_id: 1)
      end

      it_behaves_like 'バリデーションエラーにならないこと'
    end

    describe '異常系' do
      expected_error = {feature_name: 'duplicated_resource'}
      include_context 'トランザクション作成'
      before(:all) do
        create(:importance, analysis_result_id: 1)
        @object = build(:importance, analysis_result_id: 1)
        @object.validate
      end

      it_behaves_like 'エラーメッセージが正しいこと', expected_error
    end
  end
end

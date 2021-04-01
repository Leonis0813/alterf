# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        analysis_id: ['0' * 32],
        num_feature: [1, nil],
        state: %w[waiting processing completed error],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:analysis, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        analysis_id: ['invalid', 'g' * 32],
        num_feature: [0],
        state: %w[invalid],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:analysis, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end

  describe '#start!' do
    include_context 'トランザクション作成'
    before(:all) do
      @analysis = create(:analysis)
      @analysis.start!
    end

    it '状態が進行中になっていること' do
      is_asserted_by { @analysis.state == Analysis::STATE_PROCESSING }
    end

    it '実行開始日時が設定されていること' do
      is_asserted_by { @analysis.performed_at.present? }
    end
  end

  describe '#complete!' do
    include_context 'トランザクション作成'
    before(:all) do
      @analysis = create(:analysis)
      @analysis.complete!
    end

    it '状態が完了になっていること' do
      is_asserted_by { @analysis.state == Analysis::STATE_COMPLETED }
    end

    it '完了日時が設定されていること' do
      is_asserted_by { @analysis.completed_at.present? }
    end
  end
end

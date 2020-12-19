# coding: utf-8

require 'rails_helper'

describe Analysis::Result::DecisionTree::Node, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        node_id: [0],
        node_type: %w[root split leaf],
        group: %w[less greater],
        threshold: [0.1],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:node, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      required_keys = %i[node_id node_type]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}が指定されていない場合" do
          expected_error = absent_keys.map {|key| [key, 'absent_parameter'] }.to_h

          before(:all) do
            @object = build(:node, absent_keys.map{|key| [key, nil] }.to_h)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        node_id: [-1, 0.1],
        node_type: %w[invalid],
        group: %w[invalid],
        threshold: %w[invalid],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:node, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context 'node_idが重複している場合' do
        expected_error = {node_id: 'duplicated_resource'}
        include_context 'トランザクション作成'
        before(:all) do
          create(:node, analysis_result_decision_tree_id: 1)
          @object = build(:node, analysis_result_decision_tree_id: 1)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end

# coding: utf-8

require 'rails_helper'

describe Analysis::Result::DecisionTree, type: :model do
  fixture_dir = Rails.root.join('spec/fixtures')
  tmp_dir = Rails.root.join('tmp/files/analyses')

  describe '#validates' do
    describe '正常系' do
      include_context 'トランザクション作成'
      before(:all) do
        create(:decision_tree, analysis_result_id: 2)
        @object = build(:decision_tree, analysis_result_id: 1)
      end

      it_behaves_like 'バリデーションエラーにならないこと'
    end

    describe '異常系' do
      context 'tree_idが指定されていない場合' do
        expected_error = {tree_id: 'absent_parameter'}

        before(:all) do
          @object = build(:decision_tree, tree_id: nil)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end

      invalid_attribute = {
        tree_id: [-1, 0.1],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:decision_tree, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context 'tree_idが重複している場合' do
        expected_error = {tree_id: 'duplicated_resource'}
        include_context 'トランザクション作成'
        before(:all) do
          create(:decision_tree, analysis_result_id: 1)
          @object = build(:decision_tree, analysis_result_id: 1)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end

  describe '#import!' do
    describe '正常系' do
      include_context 'トランザクション作成'
      before(:all) do
        @analysis = create(:analysis)
        @analysis.result.decision_trees.first.nodes.destroy_all

        output_dir = File.join(tmp_dir, @analysis.id.to_s)
        FileUtils.mkdir_p(output_dir)
        FileUtils.cp(File.join(fixture_dir, 'tree_0.yml'), output_dir)

        @analysis.result.decision_trees.first.import!
        @nodes = @analysis.result.decision_trees.first.nodes
      end

      it 'DBにノード情報が登録されていること' do
        tree = YAML.load_file(File.join(fixture_dir, 'tree_0.yml'))
        tree['nodes'].each do |node|
          is_asserted_by { @nodes.exists?(node.except('parent_id')) }
        end
      end
    end
  end
end

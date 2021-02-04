# coding: utf-8

require 'rails_helper'

describe Analysis::Result, type: :model do
  fixture_dir = Rails.root.join('spec/fixtures')
  tmp_dir = Rails.root.join('tmp/files/analyses')

  describe '#import!' do
    describe '正常系' do
      include_context 'トランザクション作成'
      before(:all) do
        @analysis = create(:analysis)
        @analysis.result.decision_trees.destroy_all

        output_dir = File.join(tmp_dir, @analysis.id.to_s)
        FileUtils.mkdir_p(output_dir)
        FileUtils.cp(File.join(fixture_dir, 'metadata.yml'), output_dir)
        FileUtils.cp(File.join(fixture_dir, 'tree_0.yml'), output_dir)

        @analysis.result.import!
        @result = @analysis.result
      end
      after(:all) { FileUtils.rm_rf(File.join(tmp_dir, @analysis.id.to_s)) }

      it 'DBに重要度情報が登録されていること' do
        metadata = YAML.load_file(File.join(fixture_dir, 'metadata.yml'))
        metadata['importance'].each do |feature_name, _|
          is_asserted_by { @result.importances.exists?(feature_name: feature_name) }
        end
      end

      it 'DBに決定木情報が登録されていること' do
        is_asserted_by { @result.decision_trees.exists?(tree_id: 0) }

        tree = YAML.load_file(File.join(fixture_dir, 'tree_0.yml'))
        nodes = @result.decision_trees.first.nodes
        is_asserted_by { nodes.size == tree['nodes'].size }

        tree['nodes'].each do |node|
          is_asserted_by { nodes.exists?(node.except('parent_id')) }
        end
      end
    end

    describe '異常系' do
      context '分析結果ファイルが存在しない場合' do
        include_context 'トランザクション作成'
        before(:all) { @analysis = create(:analysis) }

        it 'StandardErrorが発生すること' do
          error = begin
                    @analysis.result.import!
                  rescue StandardError => e
                    e
                  end

          is_asserted_by { error.is_a?(StandardError) }
        end
      end
    end
  end
end

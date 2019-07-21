# coding: utf-8

require 'rails_helper'

describe Prediction, type: :model do
  default_attribute = {model: 'model', test_data: 'test_data', state: 'processing'}

  shared_context '予測ジョブ情報を作成する' do |attribute: default_attribute|
    before(:all) { @prediction = Prediction.create!(attribute) }
  end

  shared_examples '結果をインポートすると例外が発生すること' do |file, e|
    it_is_asserted_by do
      begin
        @prediction.import_results(file)
      rescue e
        true
      end
    end
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        model: %w[model],
        test_data: %w[test_data],
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
        model: [1.0, 0, true, nil],
        test_data: [1.0, 0, true, nil],
        state: ['invalid', nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "フォームに#{attribute.keys.join(',')}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していること',
                          absent_keys: invalid_attribute.keys - attribute.keys,
                          invalid_keys: attribute.keys - %i[model test_data]
        end
      end
    end
  end

  describe '#destroy' do
    describe '正常系' do
      include_context 'トランザクション作成'
      include_context '予測ジョブ情報を作成する'
      before(:all) { @other_prediction = @prediction }
      include_context '予測ジョブ情報を作成する'
      before(:all) do
        @prediction.results.create!(number: 1)
        @other_prediction.results.create!(number: 1)
        @prediction.destroy
      end

      it '紐づいているPrediction::Resultが削除されていること' do
        query = {predictable_id: @prediction.id, predictable_type: 'Prediction'}
        is_asserted_by { not Prediction::Result.exists?(query) }
      end

      it '紐づいていないPrediction::Resultが削除されていないこと' do
        query = {predictable_id: @other_prediction.id, predictable_type: 'Prediction'}
        is_asserted_by { Prediction::Result.exists?(query) }
      end
    end
  end

  describe '#import_results' do
    describe '正常系' do
      file = Rails.root.join('spec', 'fixtures', 'prediction.yml')
      include_context 'トランザクション作成'
      include_context '予測ジョブ情報を作成する'
      before(:all) { @prediction.import_results(file) }

      it '予測結果情報が登録されていること' do
        is_asserted_by { @prediction.results.map(&:number).sort == [3, 5, 11, 17] }
      end
    end

    describe '異常系' do
      context 'ファイルが存在しない場合' do
        file = Rails.root.join('spec', 'fixtures', 'not_exist.yml')
        include_context 'トランザクション作成'
        include_context '予測ジョブ情報を作成する'

        it_behaves_like '結果をインポートすると例外が発生すること', file, Errno::ENOENT
      end

      context 'ファイル内容が不正な場合' do
        context '配列の場合' do
          file = Rails.root.join('spec', 'fixtures', 'array.yml')
          include_context 'トランザクション作成'
          include_context '予測ジョブ情報を作成する'
          before(:all) { File.open(file, 'w') {|f| YAML.dump([3, 5, 11, 17], f) } }
          after(:all) { FileUtils.rm(file) }

          it_behaves_like '結果をインポートすると例外が発生すること',
                          file, ActiveRecord::RecordInvalid
        end

        context 'ハッシュの値が数値でない場合' do
          file = Rails.root.join('spec', 'fixtures', 'invalid_value.yml')
          include_context 'トランザクション作成'
          include_context '予測ジョブ情報を作成する'
          before(:all) { File.open(file, 'w') {|f| YAML.dump({'invalid' => 1}, f) } }
          after(:all) { FileUtils.rm(file) }

          it_behaves_like '結果をインポートすると例外が発生すること',
                          file, ActiveRecord::RecordInvalid
        end
      end
    end
  end
end

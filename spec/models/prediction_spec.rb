# coding: utf-8

require 'rails_helper'

describe Prediction, type: :model do
  default_attribute = {model: 'model', test_data: 'test_data', state: 'processing'}

  shared_context '予測ジョブ情報を作成する' do |attribute: default_attribute|
    before(:all) { @prediction = Prediction.create!(attribute) }
  end

  shared_examples '結果をインポートすると例外が発生すること' do |file, e|
    it_is_asserted_by do
      @prediction.import_results(file)
    rescue e
      true
    end
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        model: %w[model],
        test_data: %w[test_data],
        state: %w[processing completed error],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        state: ['invalid', nil],
      }

      it_behaves_like '必須パラメーターがない場合のテスト', %i[model test_data state]
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
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

      it '予測結果情報が正しく登録されていること' do
        won = [3, 5, 11, 17]
        is_asserted_by do
          @prediction.results.where(won: true).map(&:number).sort == won
        end

        is_asserted_by do
          @prediction.results.where(won: false).map(&:number).sort == (1..18).to_a - won
        end
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

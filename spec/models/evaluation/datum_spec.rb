# coding: utf-8

require 'rails_helper'

describe Evaluation::Datum, type: :model do
  default_attribute = {
    evaluation_id: 1,
    race_name: 'race_name',
    race_url: 'race_url',
    ground_truth: 1,
  }

  shared_context '評価データ情報を作成する' do |attribute: default_attribute|
    before(:all) { @evaluation_datum = Evaluation::Datum.create!(attribute) }
  end

  shared_examples '結果をインポートすると例外が発生すること' do |file, e|
    it_is_asserted_by do
      @evaluation_datum.import_prediction_results(file)
    rescue e
      true
    end
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        race_name: %w[race_name],
        race_url: %w[race_url],
        ground_truth: [1],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        ground_truth: [0],
      }
      absent_keys = %i[race_name race_url ground_truth]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end

  describe '#destroy' do
    describe '正常系' do
      include_context 'トランザクション作成'
      include_context '評価データ情報を作成する'
      before(:all) { @other_evaluation_datum = @evaluation_datum }
      include_context '評価データ情報を作成する'
      before(:all) do
        @evaluation_datum.prediction_results.create!(number: 1)
        @other_evaluation_datum.prediction_results.create!(number: 1)
        @evaluation_datum.destroy
      end

      it '紐づいているPrediction::Resultが削除されていること' do
        is_asserted_by do
          query = {
            predictable_id: @evaluation_datum.id,
            predictable_type: 'Evaluation::Datum',
          }
          not Prediction::Result.exists?(query)
        end
      end

      it '紐づいていないPrediction::Resultが削除されていないこと' do
        is_asserted_by do
          query = {
            predictable_id: @other_evaluation_datum.id,
            predictable_type: 'Evaluation::Datum',
          }
          Prediction::Result.exists?(query)
        end
      end
    end
  end

  describe '#import_prediction_results' do
    describe '正常系' do
      file = Rails.root.join('spec', 'fixtures', 'prediction.yml')
      include_context 'トランザクション作成'
      include_context '評価データ情報を作成する'
      before(:all) { @evaluation_datum.import_prediction_results(file) }

      it '予測結果情報が登録されていること' do
        won = [3, 5, 11, 17]
        results = @evaluation_datum.prediction_results

        is_asserted_by { results.where(won: true).pluck(:number).sort == won }

        is_asserted_by do
          results.where(won: false).pluck(:number).sort == (1..18).to_a - won
        end
      end
    end

    describe '異常系' do
      context 'ファイルが存在しない場合' do
        file = Rails.root.join('spec', 'fixtures', 'not_exist.yml')
        include_context 'トランザクション作成'
        include_context '評価データ情報を作成する'

        it_behaves_like '結果をインポートすると例外が発生すること', file, Errno::ENOENT
      end

      context 'ファイル内容が不正な場合' do
        context '配列の場合' do
          file = Rails.root.join('spec', 'fixtures', 'array.yml')
          include_context 'トランザクション作成'
          include_context '評価データ情報を作成する'
          before(:all) { File.open(file, 'w') {|f| YAML.dump([3, 5, 11, 17], f) } }
          after(:all) { FileUtils.rm(file) }

          it_behaves_like '結果をインポートすると例外が発生すること',
                          file, ActiveRecord::RecordInvalid
        end

        context 'ハッシュの値が数値でない場合' do
          file = Rails.root.join('spec', 'fixtures', 'invalid_value.yml')
          include_context 'トランザクション作成'
          include_context '評価データ情報を作成する'
          before(:all) { File.open(file, 'w') {|f| YAML.dump({'invalid' => 1}, f) } }
          after(:all) { FileUtils.rm(file) }

          it_behaves_like '結果をインポートすると例外が発生すること',
                          file, ActiveRecord::RecordInvalid
        end
      end
    end
  end
end

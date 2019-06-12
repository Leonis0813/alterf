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

  shared_examples '結果をインポートすると例外が発生すること' do |file, klass|
    it_is_asserted_by do
      begin
        @evaluation_datum.import_prediction_results(file)
      rescue klass
        true
      end
    end
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        race_name: %w[race_name],
        race_url: %w[race_url],
        ground_truth: [1],
      }

      test_cases = CommonHelper.generate_test_case(valid_attribute).select do |test_case|
        test_case.keys == valid_attribute.keys
      end

      test_cases.each do |attribute|
        context "フォームに#{attribute.keys.join(',')}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        race_name: [1.0, 0, true, nil],
        race_url: [1.0, 0, true, nil],
        ground_truth: ['invalid', 1.0, 0, true, nil],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "フォームに#{attribute.keys.join(',')}を指定した場合" do
          include_context 'オブジェクトを検証する', attribute
          it_behaves_like 'エラーが発生していること',
                          absent_keys: invalid_attribute.keys - attribute.keys,
                          invalid_keys: attribute.keys - %i[race_name race_url]
        end
      end
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
          not Prediction::Result.exists?(
                predictable_id: @evaluation_datum.id,
                predictable_type: 'Evaluation::Datum',
              )
        end
      end

      it '紐づいていないPrediction::Resultが削除されていないこと' do
        is_asserted_by do
          Prediction::Result.exists?(
            predictable_id: @other_evaluation_datum.id,
            predictable_type: 'Evaluation::Datum',
          )
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
        is_asserted_by do
          @evaluation_datum.prediction_results.map(&:number).sort == [3, 5, 11, 17]
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

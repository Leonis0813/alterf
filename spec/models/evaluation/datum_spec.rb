# coding: utf-8

require 'rails_helper'

describe Evaluation::Datum, type: :model do
  default_attribute = {
    evaluation_id: 1,
    race_id: '0',
    race_name: 'race_name',
    race_url: 'race_url',
    ground_truth: 1,
  }

  shared_context '評価データ情報を作成する' do |attribute: default_attribute|
    before do
      @evaluation ||= create(:evaluation)
      @evaluation_datum = @evaluation.data.create!(attribute)
    end
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
        race_id: %w[0],
        race_name: %w[race_name],
        race_url: %w[race_url],
        ground_truth: [1],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:datum, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      required_keys = %i[race_id race_name race_url ground_truth]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}が指定されていない場合" do
          expected_error = absent_keys.map {|key| [key, 'absent_parameter'] }.to_h

          before(:all) do
            attribute = absent_keys.map {|key| [key, nil] }.to_h
            @object = build(:datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        race_id: %w[invalid],
        ground_truth: [0],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:datum, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end

  describe '#destroy' do
    describe '正常系' do
      include_context 'トランザクション作成'
      include_context '評価データ情報を作成する'
      before { @other_evaluation_datum = @evaluation_datum }
      include_context '評価データ情報を作成する'
      before do
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
      file = Rails.root.join('spec/fixtures/prediction.yml')
      include_context 'トランザクション作成'
      include_context 'ActionCableのモックを作成'
      include_context '評価データ情報を作成する'
      before do
        @called = false
        @evaluation_datum.import_prediction_results(file)
      end

      it '予測結果情報が登録されていること' do
        won = [3, 5, 11, 17]
        results = @evaluation_datum.prediction_results

        is_asserted_by { results.where(won: true).pluck(:number).sort == won }

        is_asserted_by do
          results.where(won: false).pluck(:number).sort == (1..18).to_a - won
        end
      end

      it '予測結果がブロードキャストされていること' do
        is_asserted_by { @called }
      end
    end

    describe '異常系' do
      context 'ファイルが存在しない場合' do
        file = Rails.root.join('spec/fixtures/not_exist.yml')
        include_context 'トランザクション作成'
        include_context '評価データ情報を作成する'

        it_behaves_like '結果をインポートすると例外が発生すること', file, Errno::ENOENT
      end

      context 'ファイル内容が不正な場合' do
        context '配列の場合' do
          file = Rails.root.join('spec/fixtures/array.yml')
          include_context 'トランザクション作成'
          include_context '評価データ情報を作成する'
          before(:all) { File.open(file, 'w') {|f| YAML.dump([3, 5, 11, 17], f) } }
          after(:all) { FileUtils.rm(file) }

          it_behaves_like '結果をインポートすると例外が発生すること',
                          file, ActiveRecord::RecordInvalid
        end

        context 'ハッシュの値が数値でない場合' do
          file = Rails.root.join('spec/fixtures/invalid_value.yml')
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

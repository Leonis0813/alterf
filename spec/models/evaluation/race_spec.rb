# coding: utf-8

require 'rails_helper'

describe Evaluation::Race, type: :model do
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
      @evaluation_race = @evaluation.races.create!(attribute)
    end
  end

  shared_examples '結果をインポートすると例外が発生すること' do |file, e|
    it_is_asserted_by do
      @evaluation_race.import_prediction_results!(file)
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
          before(:all) { @object = build(:evaluation_race, attribute) }

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
            @object = build(:evaluation_race, attribute)
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
            @object = build(:evaluation_race, attribute)
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
      before { @other_evaluation_race = @evaluation_race }
      include_context '評価データ情報を作成する'
      before do
        @evaluation_race.test_data.create!(number: 1)
        @other_evaluation_race.test_data.create!(number: 1)
        @evaluation_race.destroy
      end

      it '紐づいているEvaluation::Race::TestDatumが削除されていること' do
        is_asserted_by do
          query = {evaluation_race_id: @evaluation_race.id}
          not Evaluation::Race::TestDatum.exists?(query)
        end
      end

      it '紐づいていないPrediction::Resultが削除されていないこと' do
        is_asserted_by do
          query = {evaluation_race_id: @other_evaluation_race.id}
          Evaluation::Race::TestDatum.exists?(query)
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
        @evaluation_race.import_prediction_results!(file)
      end

      it '予測結果情報が登録されていること' do
        won = [3, 5, 11, 17]
        lose = (1..18).to_a - won
        test_data = @evaluation_race.test_data

        is_asserted_by do
          test_data.where(prediction_result: true).pluck(:number).sort == won
        end

        is_asserted_by do
          test_data.where(prediction_result: false).pluck(:number).sort == lose
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

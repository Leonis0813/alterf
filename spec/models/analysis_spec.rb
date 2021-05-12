# coding: utf-8

require 'rails_helper'

describe Analysis, type: :model do
  shared_context '一時ディレクトリを作成する' do
    before do
      @tmp_dir = Rails.root.join('tmp/files/analyses', @analysis.id.to_s)
      FileUtils.mkdir_p(@tmp_dir)
    end

    after { FileUtils.rm_rf(@tmp_dir) }
  end

  shared_examples '更新した状態がブロードキャストされていること' do |state|
    it "状態が#{state}になっていること" do
      is_asserted_by { @analysis.state == state }
    end

    it '状態がブロードキャストされていること' do
      is_asserted_by { @called }
    end
  end

  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        analysis_id: ['0' * 32],
        data_source: %w[random file],
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
        data_source: %w[invalid],
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
    include_context 'ActionCableのモックを作成'
    before do
      @analysis = create(:analysis)
      @analysis.start!
    end

    it '実行開始日時が設定されていること' do
      is_asserted_by { @analysis.performed_at.present? }
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Analysis::STATE_PROCESSING
  end

  describe '#complete!' do
    include_context 'トランザクション作成'
    include_context 'ActionCableのモックを作成'
    before do
      @analysis = create(:analysis, performed_at: Time.zone.now)
      @analysis.complete!
    end

    it '完了日時が設定されていること' do
      is_asserted_by { @analysis.completed_at.present? }
    end

    it_behaves_like '更新した状態がブロードキャストされていること',
                    Analysis::STATE_COMPLETED
  end

  describe '#dump_parameter' do
    include_context 'トランザクション作成'

    [
      ['エントリー数を指定しない場合', {}],
      ['エントリー数を指定する場合', {num_entry: 10}],
    ].each do |desc, attribute|
      context desc do
        before { @analysis = create(:analysis, attribute) }
        include_context '一時ディレクトリを作成する'
        before do
          attribute.merge!(@analysis.slice(:data_source, :num_data).merge(env: 'test'))
          @expected_parameter = @analysis.parameter
                                         .slice(*parameter_attribute_names)
                                         .merge(attribute)
                                         .stringify_keys

          @analysis.dump_parameter
          @parameter = YAML.load_file(File.join(@tmp_dir, 'parameter.yml'))
        end

        it 'パラメーターが出力されていること' do
          is_asserted_by { @parameter == @expected_parameter }
        end
      end
    end
  end

  describe '#dump_training_data' do
    include_context 'トランザクション作成'

    context '指定方法がランダムの場合' do
      before { @analysis = create(:analysis, {data_source: 'random'}) }
      include_context '一時ディレクトリを作成する'
      before { @analysis.dump_training_data }

      it '学習データが出力されていないこと' do
        is_asserted_by { not File.exist?(File.join(@tmp_dir, 'training_data.txt')) }
      end
    end

    context '指定方法がファイルの場合' do
      before { @analysis = create(:analysis, {data_source: 'file'}) }
      include_context '一時ディレクトリを作成する'
      before do
        @analysis.dump_training_data

        file_path = File.join(@tmp_dir, 'training_data.txt')
        @race_ids = File.read(file_path).lines.map(&:chomp)
      end

      it 'レースIDが出力されていること' do
        is_asserted_by { @race_ids == @analysis.data.pluck(:race_id) }
      end
    end
  end

  describe '#import_data!' do
    race_id = '12345'

    [
      ['ランダム', 'random', [race_id]],
      ['ファイル', 'file', []],
    ].each do |desc, data_source, expected_race_ids|
      context "指定方法が#{desc}の場合" do
        include_context 'トランザクション作成'
        before { @analysis = create(:analysis, {data_source: data_source, data: []}) }
        include_context '一時ディレクトリを作成する'
        before do
          File.open(File.join(@tmp_dir, 'race_list.txt'), 'w') do |file|
            file.puts(race_id)
          end
          @analysis.import_data!
        end

        it '学習データが正しいこと' do
          is_asserted_by { @analysis.data.pluck(:race_id) == expected_race_ids }
        end
      end
    end
  end

  describe '#copy' do
    include_context 'トランザクション作成'
    before do
      @analysis = create(:analysis)
      @copied_analysis = @analysis.copy
    end

    it '分析ジョブ情報がコピーされていること' do
      attribute_names = %i[data_source num_data num_entry]
      is_asserted_by do
        @analysis.slice(*attribute_names) == @copied_analysis.slice(*attribute_names)
      end
    end

    it '分析パラメーター情報がコピーされていること' do
      parameter = @analysis.parameter.slice(*parameter_attribute_names)
      copied_parameter = @copied_analysis.parameter.slice(*parameter_attribute_names)
      is_asserted_by { parameter == copied_parameter }
    end

    it '分析データ情報がコピーされていること' do
      data = @analysis.data.map(&:race_id)
      copied_data = @copied_analysis.data.map(&:race_id)
      is_asserted_by { data == copied_data }
    end
  end
end

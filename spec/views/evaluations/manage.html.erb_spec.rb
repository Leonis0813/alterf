# coding: utf-8

require 'rails_helper'

describe 'evaluations/manage', type: :view do
  per_page = 1
  default_attribute = {evaluation_id: '0' * 32, model: 'model', state: 'processing'}

  shared_context '評価ジョブを作成する' do |total: per_page, update_attribute: {}|
    before(:all) do
      attribute = default_attribute.merge(update_attribute)
      total.times do
        evaluation = Evaluation.create!(attribute)
        evaluation.data.create!(
          race_id: '1' * 8,
          race_name: 'race_name',
          race_url: 'race_url',
          ground_truth: 1,
        )
      end
      @evaluations = Evaluation.order(created_at: :desc).page(1)
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like '表示件数情報が表示されていること',
                    total: expected[:total] || per_page,
                    from: expected[:from] || 1,
                    to: expected[:to] || per_page
    it_behaves_like 'テーブルが表示されていること',
                    rows: expected[:rows] || per_page
  end

  shared_examples '入力フォームが表示されていること' do
    it 'タイトルが表示されていること' do
      title = @html.xpath("#{form_panel_xpath}/div[@id='new-evaluation']/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text == 'モデルを評価' }
    end

    %w[model data].each do |param|
      it "evaluation_#{param}を含む<label>タグがあること" do
        label =
          @html.xpath("#{input_xpath('evaluation')}/label[@for='evaluation_#{param}']")
        is_asserted_by { label.present? }
      end
    end

    it 'evaluation_modelを含む<input>タグがあること' do
      input =
        @html.xpath("#{input_xpath('evaluation')}/input[@id='evaluation_model']")
      is_asserted_by { input.present? }
    end

    it 'data_sourceを含む<label>タグがあること' do
      xpath = "#{input_xpath('evaluation')}/span/label[@for='data_source']"
      is_asserted_by { @html.xpath(xpath).present? }
    end

    it 'data_sourceを含む<select>タグがあること' do
      xpath = "#{input_xpath('evaluation')}/span/select[@id='data_source']"
      is_asserted_by { @html.xpath(xpath).present? }
    end

    [
      %w[remote Top20],
      %w[file ファイル],
      %w[text 直接入力],
      %w[random ランダム],
    ].each do |value, text|
      it "valueが#{value}の<option>タグがあること" do
        xpath = "#{input_xpath('evaluation')}/span/select[@id='data_source']" \
                "/option[@value='#{value}']"
        is_asserted_by { @html.xpath(xpath).present? }
        is_asserted_by { @html.xpath(xpath).text == text }
      end
    end

    it '非表示で無効になっているファイル入力フォームがあること' do
      xpath = "#{input_xpath('evaluation')}/input[@id='evaluation_data_file']" \
              "[@class='form-control form-data-source not-selected'][@disabled]"
      is_asserted_by { @html.xpath(xpath).present? }
    end

    it '非表示で無効になっているテキスト入力フォームがあること' do
      xpath = "#{input_xpath('evaluation')}/textarea[@id='evaluation_data_text']" \
              "[@class='form-control form-data-source not-selected'][@disabled]"
      is_asserted_by { @html.xpath(xpath).present? }
    end

    it '非表示で無効になっているデータ数入力フォームがあること' do
      xpath = "#{input_xpath('evaluation')}/input[@id='evaluation_data_random']" \
              "[@class='form-control form-data-source not-selected'][@disabled]"
      is_asserted_by { @html.xpath(xpath).present? }
    end

    %w[submit reset].each do |type|
      it "typeが#{type}のボタンがあること" do
        button = @html.xpath("#{form_xpath('evaluation')}/input[@type='#{type}']")
        is_asserted_by { button.present? }
      end
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 0|
    before(:each) do
      @table = @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']")
    end

    it '8列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 8 }
    end

    %w[実行開始日時 モデル 状態 適合率 再現率 F値].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples 'ジョブの状態が正しいこと' do |state|
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      rows.each do |row|
        is_asserted_by { row.xpath('//td')[2].text.strip == state }
      end
    end
  end

  shared_examples '評価結果情報が表示されていること' do
    before(:each) do
      @rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
    end

    it '適合率が表示されていること' do
      @evaluations.each_with_index do |evaluation, i|
        precision = @rows[i].children.search('td')[3]
        is_asserted_by { precision.text.strip == evaluation.precision.round(3).to_s }
      end
    end

    it '再現率が表示されていること' do
      @evaluations.each_with_index do |evaluation, i|
        precision = @rows[i].children.search('td')[4]
        is_asserted_by { precision.text.strip == evaluation.recall.round(3).to_s }
      end
    end

    it 'F値が表示されていること' do
      @evaluations.each_with_index do |evaluation, i|
        precision = @rows[i].children.search('td')[5]
        is_asserted_by { precision.text.strip == evaluation.f_measure.round(3).to_s }
      end
    end

    it_behaves_like '詳細ボタンが表示されていること'
  end

  shared_examples '詳細ボタンが表示されていること' do |button_class = 'success'|
    before(:each) do
      @rows ||=
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
    end

    it '矢印が表示されていること' do
      @evaluations.each_with_index do |_, i|
        cell = @rows[i].children.search('td')[6].children
        is_asserted_by do
          cell.search('span[@class="glyphicon glyphicon-arrow-right"]').present?
        end
      end
    end

    it '結果画面へのボタンが表示されていること' do
      @evaluations.each_with_index do |evaluation, i|
        cell = @rows[i].children.search('td')[7].children
        href = "/evaluations/#{evaluation.evaluation_id}"
        is_asserted_by { cell.search('a').attribute('href').value == href }

        button = cell.search("a/button[@class='btn btn-#{button_class} btn-result']")
        is_asserted_by { button.present? }
        is_asserted_by { button.text.strip == '詳細' }
        is_asserted_by do
          button.children
                .search('span[@class="glyphicon glyphicon-new-window new-window"]')
                .present?
        end
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @evaluation = Evaluation.new
  end

  before(:each) do
    render template: 'evaluations/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行中の場合' do
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '0%完了'
    it_behaves_like '詳細ボタンが表示されていること', 'warning'
  end

  context '完了している場合' do
    update_attribute = {state: 'completed', precision: 0.75, recall: 0.5, f_measure: 0.6}
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '完了'
    it_behaves_like '評価結果情報が表示されていること'
  end

  context 'エラーの場合' do
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する', update_attribute: {state: 'error'}
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', 'エラー'
  end

  context "評価ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する', total: total
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'evaluation'
  end
end

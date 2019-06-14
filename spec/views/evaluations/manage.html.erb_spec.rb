# coding: utf-8

require 'rails_helper'

describe 'evaluations/manage', type: :view do
  per_page = 1
  default_attribute = {evaluation_id: '0' * 32, model: 'model', state: 'processing'}

  shared_context '評価ジョブを作成する' do |total: per_page, update_attribute: {}|
    before(:all) do
      attribute = default_attribute.merge(update_attribute)
      total.times { Evaluation.create!(attribute) }
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

    %w[model].each do |param|
      it "evaluation_#{param}を含む<label>タグがあること" do
        label =
          @html.xpath("#{input_xpath('evaluation')}/label[@for='evaluation_#{param}']")
        is_asserted_by { label.present? }
      end

      it "evaluation_#{param}を含む<input>タグがあること" do
        input =
          @html.xpath("#{input_xpath('evaluation')}/input[@id='evaluation_#{param}']")
        is_asserted_by { input.present? }
      end
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

    it '6列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 6 }
    end

    %w[実行開始日時 モデル 状態 精度].each_with_index do |text, i|
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

    it '精度が表示されていること' do
      @evaluations.each_with_index do |evaluation, i|
        precision = @rows[i].children.search('td')[3]
        is_asserted_by { precision.text.strip == "#{evaluation.precision}%" }
      end
    end

    it '矢印が表示されていること' do
      @evaluations.each_with_index do |_, i|
        cell = @rows[i].children.search('td')[4].children
        is_asserted_by do
          cell.search('span[@class="glyphicon glyphicon-arrow-right"]').present?
        end
      end
    end

    it '結果画面へのボタンが表示されていること' do
      @evaluations.each_with_index do |evaluation, i|
        cell = @rows[i].children.search('td')[5].children
        href = "/evaluations/#{evaluation.evaluation_id}"
        is_asserted_by { cell.search('a').attribute('href').value == href }

        button = cell.search('a/button[@class="btn btn-success btn-result"]')
        is_asserted_by { button.present? }
        is_asserted_by { button.text.strip == '詳細' }
        is_asserted_by do
          button.children
                .search('span[@class="glyphicon glyphicon-new-window"]').present?
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
    it_behaves_like 'ジョブの状態が正しいこと', '実行中'
  end

  context '完了している場合' do
    include_context 'トランザクション作成'
    include_context '評価ジョブを作成する',
                    update_attribute: {state: 'completed', precision: 75.0}
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

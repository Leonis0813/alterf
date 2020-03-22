# coding: utf-8

require 'rails_helper'

describe 'analyses/manage', type: :view do
  per_page = 1
  default_attribute = {num_data: 10000, num_tree: 100}

  shared_context '分析ジョブを作成する' do |total: per_page, update_attribute: {}|
    before(:all) do
      attribute = default_attribute.merge(update_attribute)
      total.times {|i| create(:analysis, attribute.merge(analysis_id: i.to_s * 32)) }
      @analyses = Analysis.order(created_at: :desc).page(1)
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
      title = @html.xpath("#{form_panel_xpath}/div[@id='new-analysis']/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text == 'レースを分析' }
    end

    %w[num_data num_tree num_entry].each do |param|
      it "analysis_#{param}を含む<label>タグがあること" do
        label = @html.xpath("#{input_xpath('analysis')}/label[@for='analysis_#{param}']")
        is_asserted_by { label.present? }
      end

      it "analysis_#{param}を含む<input>タグがあること" do
        input = @html.xpath("#{input_xpath('analysis')}/input[@id='analysis_#{param}']")
        is_asserted_by { input.present? }
      end
    end

    %w[submit reset].each do |type|
      it "typeが#{type}のボタンがあること" do
        button = @html.xpath("#{form_xpath('analysis')}/input[@type='#{type}']")
        is_asserted_by { button.present? }
      end
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 0|
    before(:each) do
      @table = @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']")
    end

    it '7列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 7 }
    end

    %w[実行開始日時 学習データ数 決定木の数 特徴量の数 エントリー数 状態].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it '再実行ボタンが配置されている列があること' do
      xpath = [
        table_panel_xpath,
        'table[@class="table table-hover"]',
        'thead',
        'th[@class="rebuild"]',
      ].join('/')
      header_rebuild = @table.xpath(xpath)
      is_asserted_by { header_rebuild.present? }
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples 'ジョブの状態が正しいこと' do |state, num_entry: 0|
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      rows.each do |row|
        is_asserted_by { row.search('td')[5].text.strip == state }
      end
    end

    it '実行中の場合はアイコンが表示されていること', if: state == '実行中' do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      rows.each do |row|
        td_children = row.search('td')[5].children

        is_asserted_by { td_children.search('span[@class="processing"]').present? }

        is_asserted_by do
          td_children.search('i[@class="fa fa-refresh fa-spin"]').present?
        end
      end
    end

    it 'エントリー数が表示されていること', if: num_entry > 0 do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      rows.each do |row|
        is_asserted_by { row.search('td')[4].text.strip.to_i == num_entry }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @analysis = Analysis.new
  end

  before(:each) do
    render template: 'analyses/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行待ちの場合' do
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行待ち'
  end

  context '実行中の場合' do
    update_attribute = {state: 'processing', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行中'
  end

  context 'エントリー数が指定されている場合' do
    update_attribute = {num_entry: 10, state: 'processing', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '実行中', num_entry: 10
  end

  context '完了している場合' do
    update_attribute = {state: 'completed', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', '完了'
  end

  context 'エラーの場合' do
    update_attribute = {state: 'error', performed_at: Time.zone.now}
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', update_attribute: update_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'ジョブの状態が正しいこと', 'エラー'
  end

  context "分析ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)
    include_context 'トランザクション作成'
    include_context '分析ジョブを作成する', total: total
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'analysis'
  end
end

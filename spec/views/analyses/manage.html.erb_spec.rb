# coding: utf-8

require 'rails_helper'

describe 'analyses/manage', type: :view do
  per_page = 1

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

    %w[num_data num_tree].each do |param|
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

  shared_examples 'ページングボタンが表示されていること' do
    it '先頭のページへのボタンが表示されていないこと' do
      xpath = [
        paging_xpath,
        'li[@class="pagination"]',
        'span[@class="first"]',
        'a',
      ].join('/')
      link_first = @html.xpath(xpath)
      is_asserted_by { link_first.blank? }
    end

    it '前のページへのボタンが表示されていないこと' do
      xpath = [
        paging_xpath,
        'li[@class="pagination"]',
        'span[@class="prev"]',
        'a',
      ].join('/')
      link_prev = @html.xpath(xpath)
      is_asserted_by { link_prev.blank? }
    end

    it '1ページ目が表示されていること' do
      xpath = [
        paging_xpath,
        'li[@class="page-item active"]',
        'a[@class="page-link"]',
      ].join('/')
      link_one = @html.xpath(xpath)
      is_asserted_by { link_one.present? }
      is_asserted_by { link_one.text == '1' }
    end

    it '2ページ目へのリンクが表示されていること' do
      xpath = [
        paging_xpath,
        'li[@class="page-item"]',
        'a[@class="page-link"][@href="/analyses?page=2"]',
      ].join('/')
      link_two = @html.xpath(xpath)
      is_asserted_by { link_two.present? }
      is_asserted_by { link_two.text == '2' }
    end

    it '次のページへのボタンが表示されていること' do
      xpath = [
        paging_xpath,
        'li[@class="page-item"]',
        'span[@class="next"]',
        'a[@class="page-link"][@href="/analyses?page=2"]',
      ].join('/')
      link_next = @html.xpath(xpath)
      is_asserted_by { link_next.present? }
      is_asserted_by { link_next.text == I18n.t('views.pagination.next') }
    end

    it '最後のページへのボタンが表示されていること' do
      xpath = [
        paging_xpath,
        'li[@class="page-item"]',
        'span[@class="last"]',
        'a',
      ].join('/')
      link_last = @html.xpath(xpath)
      is_asserted_by { link_last.present? }
      is_asserted_by { link_last.text == I18n.t('views.pagination.last') }
    end

    it '3点リーダが表示されていること' do
      xpath = [
        paging_xpath,
        'li[@class="page-item disabled"]',
        'a[@href="#"]',
      ].join('/')
      link_gap = @html.xpath(xpath)
      is_asserted_by { link_gap.present? }
      is_asserted_by { link_gap.text == '...' }
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 0|
    before(:each) do
      @table = @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']")
    end

    it '6列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 6 }
    end

    %w[実行開始日時 学習データ数 決定木の数 特徴量の数 状態].each_with_index do |text, i|
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

  shared_examples 'ジョブが実行中状態になっていること' do
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      @analyses.each_with_index do |analysis, i|
        is_asserted_by { rows[i].xpath('//td')[4].text == '実行中' }
      end
    end
  end

  shared_examples 'ジョブが完了状態になっていること' do
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      @analyses.each_with_index do |analysis, i|
        is_asserted_by { rows[i].xpath('//td')[4].text == '完了' }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @analysis = Analysis.new
  end

  before(:each) do
    render template: 'analyses/manage', layout: 'layouts/application'
    @html ||= Nokogiri::parse(response)
  end

  context "分析ジョブ情報が#{per_page}件の場合" do
    context '実行中の場合' do
      include_context 'トランザクション作成'

      before(:all) do
        attribute = {num_data: 10000, num_tree: 100, state: 'processing'}
        per_page.times { Analysis.create!(attribute) }
        @analyses = Analysis.order(created_at: :desc).page(1)
      end

      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブが実行中状態になっていること'
    end

    context '完了している場合' do
      include_context 'トランザクション作成'

      before(:all) do
        attribute = {num_data: 10000, num_tree: 100, state: 'completed'}
        per_page.times { Analysis.create!(attribute) }
        @analyses = Analysis.order(created_at: :desc).page(1)
      end

      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブが完了状態になっていること'
    end
  end

  context "分析ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)

    include_context 'トランザクション作成'

    before(:all) do
      attribute = {num_data: 10000, num_tree: 100, state: 'processing'}
      total.times { Analysis.create!(attribute) }
      @analyses = Analysis.order(created_at: :desc).page(1)
    end

    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること'
  end
end

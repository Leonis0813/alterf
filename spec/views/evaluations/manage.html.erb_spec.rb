# coding: utf-8

require 'rails_helper'

describe 'evaluations/manage', type: :view do
  per_page = 1
  row_xpath = '//div[@id="main-content"]/div[@class="row center-block"]'
  table_panel_xpath = [row_xpath, 'div[@class="col-lg-8"]'].join('/')

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
    form_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-4"]',
      'div[@id="new-evaluation"]',
    ].join('/')

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{form_panel_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text == 'モデルを評価' }
    end

    form_tag_xpath = 'form[@action="/evaluations"][@data-remote="true"]' \
                     '[@method="post"][@class="new_evaluation"]'
    form_xpath = [form_panel_xpath, form_tag_xpath].join('/')
    input_xpath = "#{form_xpath}/div[@class='form-group']"

    %w[model].each do |param|
      it "evaluation_#{param}を含む<label>タグがあること" do
        label = @html.xpath("#{input_xpath}/label[@for='evaluation_#{param}']")
        is_asserted_by { label.present? }
      end

      it "evaluation_#{param}を含む<input>タグがあること" do
        input = @html.xpath("#{input_xpath}/input[@id='evaluation_#{param}']")
        is_asserted_by { input.present? }
      end
    end

    %w[submit reset].each do |type|
      it "typeが#{type}のボタンがあること" do
        button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
        is_asserted_by { button.present? }
      end
    end
  end

  shared_examples '表示件数情報が表示されていること' do |total: 0, from: 0, to: 0|
    it 'タイトルが表示されていること' do
      title = @html.xpath("#{table_panel_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text == 'ジョブ実行履歴' }
    end

    it '件数情報が表示されていること' do
      number = @html.xpath("#{table_panel_xpath}/h4")
      is_asserted_by { number.present? }
      is_asserted_by { number.text == "#{total}件中#{from}〜#{to}件を表示" }
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 0|
    before(:each) do
      @table = @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']")
    end

    it '3列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 3 }
    end

    %w[実行開始日時 モデル 状態].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples 'ページングボタンが表示されていないこと' do
    it do
      paging = @html.xpath("#{table_panel_xpath}/nav/ul[@class='pagination']")
      is_asserted_by { paging.blank? }
    end
  end

  shared_examples 'ページングボタンが表示されていること' do
    paging_xpath = [table_panel_xpath, 'nav', 'ul[@class="pagination"]'].join('/')

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
        'a[@class="page-link"][@href="/evaluations?page=2"]',
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
        'a[@class="page-link"][@href="/evaluations?page=2"]',
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

  shared_examples 'ジョブが実行中状態になっていること' do
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      @evaluations.each_with_index do |analysis, i|
        is_asserted_by { rows[i].xpath('//td')[2].text == '実行中' }
      end
    end
  end

  shared_examples 'ジョブが完了状態になっていること' do
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      @evaluations.each_with_index do |analysis, i|
        is_asserted_by { rows[i].xpath('//td')[2].text == '完了' }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @evaluation = Evaluation.new
  end

  before(:each) do
    render template: 'evaluations/manage', layout: 'layouts/application'
    @html ||= Nokogiri::parse(response)
  end

  context "評価ジョブ情報が#{per_page}件の場合" do
    context '実行中の場合' do
      before(:all) do
        attribute = {model: 'model', state: 'processing'}
        per_page.times { Evaluation.create!(attribute) }
        @evaluations = Evaluation.order(created_at: :desc).page(1)
      end

      after(:all) { Evaluation.destroy_all }

      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブが実行中状態になっていること'
    end

    context '完了している場合' do
      before(:all) do
        attribute = {model: 'model', state: 'completed'}
        per_page.times { Evaluation.create!(attribute) }
        @evaluations = Evaluation.order(created_at: :desc).page(1)
      end

      after(:all) { Evaluation.destroy_all }

      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'ジョブが完了状態になっていること'
    end
  end

  context "評価ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)

    before(:all) do
      attribute = {model: 'model', state: 'processing'}
      total.times { Evaluation.create!(attribute) }
      @evaluations = Evaluation.order(created_at: :desc).page(1)
    end

    after(:all) { Evaluation.destroy_all }

    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること'
  end
end

# coding: utf-8
require 'rails_helper'

describe 'analyses/manage', :type => :view do
  per_page = 1
  row_xpath = '//div[@id="main-content"]/div[@class="row center-block"]'

  shared_context '分析ジョブを登録する' do |num|
    before(:all) do
      param = {:num_data => 10000, :num_tree => 100}
      num.times { Analysis.create!(param.merge(:state => %w[processing completed].sample)) }
      @analyses = Analysis.order(:created_at => :desc).page(1)
    end

    after(:all) { Analysis.destroy_all }
  end

  shared_examples '入力フォームが表示されていること' do
    form_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-4"]',
      'div[@id="new-analysis"]',
    ].join('/')

    it 'タイトルが表示されていること'do
      expect(@html).to have_selector("#{form_panel_xpath}/h3", :text => 'レースを分析')
    end

    form_xpath = [
      form_panel_xpath,
      'form[action="/analyses"][data-remote=true][method="post"][@class="new_analysis"]',
    ].join('/')

    %w[ num_data num_tree ].each do |param|
      input_xpath = "#{form_xpath}/div[@class='form-group']"

      it "analysis_#{param}を含む<label>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/label[for='analysis_#{param}']")
      end

      it "analysis_#{param}を含む<input>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/input[id='analysis_#{param}']")
      end
    end

    %w[ submit reset ].each do |type|
      it "typeが#{type}のボタンがあること" do
        expect(@html).to have_selector("#{form_xpath}/input[type='#{type}']")
      end
    end
  end

  shared_examples 'ジョブ実行履歴が表示されていること' do |expected_size: 0, total: 0, from: 0, to: 0|
    table_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-8"]',
    ].join('/')

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{table_panel_xpath}/h3", :text => 'ジョブ実行履歴')
    end

    it '件数情報が表示されていること' do
      info_xpath = "#{table_panel_xpath}/h4"
      expect(@html).to have_selector(info_xpath, :text => "#{total}件中#{from}〜#{to}件を表示")
    end

    paging_xpath = "#{table_panel_xpath}/nav/ul[@class='pagination']"

    it '先頭のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='first']/a"
      expect(@html).not_to have_selector(xpath, :text => I18n.t('views.list.pagination.first'))
    end

    it '前のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='prev']/a"
      expect(@html).not_to have_selector(xpath, :text => I18n.t('views.list.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item active']"
      expect(@html).to have_selector(xpath, :text => 1)
    end

    it '2ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/a[href='/analyses?page=2']"
      expect(@html).to have_selector(xpath, :text => 2)
    end

    it '次のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='next']/a[href='/analyses?page=2']"
      expect(@html).to have_selector(xpath, :text => I18n.t('views.pagination.next'))
    end

    it '最後のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='last']/a"
      expect(@html).to have_selector(xpath, :text => I18n.t('views.pagination.last'))
    end

    %w[ 実行開始日時 学習データ数 決定木の数 特徴量の数 状態 ].each do |header|
      it "ヘッダー(#{header})があること" do
        xpath = "#{table_panel_xpath}/table[@class='table table-hover']/thead/th"
        expect(@html).to have_selector(xpath, :text => header)
      end
    end

    it 'データの数が正しいこと' do
      table_body_xpath = "#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr"
      expect(@html).to have_xpath(table_body_xpath, :count => expected_size)
    end

    it '背景色が正しいこと', :if => expected_size > 0 do
      matched_data = @html.gsub("\n", '').match(/<tr\s*class='(?<color>.*?)'\s*>(?<data>.*?)<\/tr>/)
      case matched_data[:color]
      when 'warning'
        is_asserted_by { matched_data[:data].include?('実行中') }
      when 'success'
        is_asserted_by { matched_data[:data].include?('完了') }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @analysis = Analysis.new
  end

  before(:each) do
    render :template => 'analyses/manage', :layout => 'layouts/application'
    @html ||= response
  end

  describe '<html><body>' do
    include_context '分析ジョブを登録する', 10
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like 'ジョブ実行履歴が表示されていること', {
                      :expected_size => 1,
                      :total => 10,
                      :from => 1,
                      :to => 1,
                    }
  end
end

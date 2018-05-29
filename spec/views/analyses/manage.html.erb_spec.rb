# coding: utf-8
require 'rails_helper'

describe 'analyses/manage', :type => :view do
  row_xpath = '//div[@id="main-content"]/div[@class="row center-block"]'

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

    %w[ num_data num_tree num_feature ].each do |param|
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

  shared_examples 'ジョブ実行履歴が表示されていること' do
    table_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-8"]',
    ].join('/')

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{table_panel_xpath}/h4", :text => 'ジョブ実行履歴')
    end

    %w[ 実行開始日時 学習データ数 決定木の数 特徴量の数 状態 ].each do |header|
      it "ヘッダー(#{header})があること" do
        expect(@html).to have_selector("#{table_panel_xpath}/table[@class='table table-hover']/thead/th", :text => header)
      end
    end
  end

  before(:all) do
    @analysis = Analysis.new
    @analyses = Analysis.all
  end

  before(:each) do
    render :template => 'analyses/manage', :layout => 'layouts/application'
    @html ||= response
  end

  describe '<html><body>' do
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like 'ジョブ実行履歴が表示されていること'
  end
end

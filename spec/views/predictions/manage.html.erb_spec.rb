# coding: utf-8
require 'rails_helper'

describe 'predictions/manage', :type => :view do
  row_xpath = '//div[@id="main-content"]/div[@class="row center-block"]'

  shared_context '予測ジョブを登録する' do |num|
    before(:all) do
      param = {:model => 'model', :test_data => 'test_data'}
      num.times { Prediction.create!(param.merge(:state => %w[processing completed].sample)) }
      @predictions = Prediction.order(:created_at => :desc)
    end

    after(:all) { Prediction.destroy_all }
  end

  shared_examples '入力フォームが表示されていること' do
    form_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-4"]',
      'div[@id="new-prediction"]',
    ].join('/')

    it 'タイトルが表示されていること'do
      expect(@html).to have_selector("#{form_panel_xpath}/h3", :text => 'レースを予測')
    end

    form_xpath = [
      form_panel_xpath,
      'form[action="/predictions"][data-remote=true][method="post"][@class="new_prediction"]',
    ].join('/')

    %w[ model test_data ].each do |param|
      input_xpath = "#{form_xpath}/div[@class='form-group']"

      it "prediction_#{param}を含む<label>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/label[for='prediction_#{param}']")
      end

      it "prediction_#{param}を含む<input>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/input[id='prediction_#{param}']")
      end
    end

    %w[ submit reset ].each do |type|
      it "typeが#{type}のボタンがあること" do
        expect(@html).to have_selector("#{form_xpath}/input[type='#{type}']")
      end
    end
  end

  shared_examples 'ジョブ実行履歴が表示されていること' do |expected_size|
    table_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-8"]',
    ].join('/')

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{table_panel_xpath}/h4", :text => 'ジョブ実行履歴')
    end

    %w[ 実行開始日時 モデル テストデータ 状態 ].each do |header|
      it "ヘッダー(#{header})があること" do
        expect(@html).to have_selector("#{table_panel_xpath}/table[@class='table table-hover']/thead/th", :text => header)
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

  before(:all) { @prediction = Prediction.new }

  before(:each) do
    render :template => 'predictions/manage', :layout => 'layouts/application'
    @html ||= response
  end

  describe '<html><body>' do
    include_context '予測ジョブを登録する', 10
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like 'ジョブ実行履歴が表示されていること', 10
  end
end

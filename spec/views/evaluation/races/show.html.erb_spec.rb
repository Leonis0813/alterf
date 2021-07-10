# coding: utf-8

require 'rails_helper'

describe 'evaluation/races/show', type: :view do
  shared_context '評価テストデータを作成する' do |prediction_result: true|
    before(:all) do
      @race = create(:race)
      @entry = create(:entry, race_id: @race.id)
      @feature = create(:feature, race_id: @race.race_id, number: @entry.number)
      evaluation = create(:evaluation, state: 'completed')
      attribute = {evaluation_id: evaluation.id, race_id: @race.race_id}
      @evaluation_race = create(:evaluation_race, attribute)
      attribute = {
        evaluation_race_id: @evaluation_race.id,
        number: @entry.number,
        prediction_result: prediction_result,
      }
      @test_datum = create(:evaluation_race_test_datum, attribute)
    end

    after(:all) do
      @race.destroy
      @entry.destroy
      @feature.destroy
    end
  end

  shared_examples '画面共通テスト' do
    it_behaves_like 'ヘッダーが表示されていること'

    it 'タイトルが表示されていること' do
      title = @html.xpath('//div[@id="main-content"]/h4').text.strip
      is_asserted_by { title == "テストデータ - #{@evaluation_race.race_name}" }
    end

    [
      %w[raw-data 生データ],
      %w[feature 特徴量],
    ].each do |type, text|
      it "#{text}を表示するタブがあること" do
        tab_xpath = [
          '//div[@id="main-content"]',
          'ul[@class="nav nav-tabs"]',
          'li[@class="nav-item active"]',
          "button[@id='tab-#{type}']",
        ].join('/')
        tab = @html.xpath(tab_xpath)

        is_asserted_by { tab.present? }
        is_asserted_by { tab.text.strip == text }
      end

      it_behaves_like 'テーブルが表示されていること', type: type
    end
  end

  shared_examples 'テーブルが表示されていること' do |type: nil|
    before do
      xpath = [
        '//div[@id="main-content"]',
        'div[@class="tab-content"]',
        "div[@id='#{type}'][contains(@class, 'card text-dark bg-light tab-pane')]",
        'div[@class="card-body table-responsive"]',
        "table[@id='table-evaluation-race-#{type}']",
      ].join('/')
      @table = @html.xpath(xpath)
    end

    it "#{Denebola::Feature::NAMES.size}列のテーブルが表示されていること" do
      is_asserted_by do
        @table.search('thead/th').size == Denebola::Feature::NAMES.size
      end
    end

    Denebola::Feature::NAMES.each_with_index do |feature_name, i|
      it "#{i + 1}列目のヘッダーが#{feature_name}であること" do
        is_asserted_by { @table.search('thead/th')[i].text.strip == feature_name }
      end
    end

    it 'テストデータの数が正しいこと' do
      is_asserted_by do
        @table.search('tbody/tr').size == @evaluation_race.test_data.size
      end
    end
  end

  shared_examples 'テストデータが正しく表示されていること' do |td_class: nil|
    before do
      xpath = [
        '//div[@id="main-content"]',
        'div[@class="tab-content"]',
        'div[@id="raw-data"][contains(@class, "card text-dark bg-light tab-pane")]',
        'div[@class="card-body table-responsive"]',
        'table[@id="table-evaluation-race-raw-data"]',
        'tbody',
      ].join('/')
      @tbody = @html.xpath(xpath)
    end

    it 'orderのセルの色が正しいこと' do
      is_asserted_by do
        @tbody.search('td').first.attribute('class').value == 'order table-dark'
      end
    end

    it 'orderの値が表示されていること' do
      is_asserted_by { @tbody.search('td').first.text.strip == @test_datum.order.to_s }
    end

    (Denebola::Feature::NAMES - %w[order]).each.with_index(1) do |feature_name, i|
      it "#{feature_name}のセルの色が正しいこと" do
        @tbody.search('td')[i].attribute('class').value == "#{feature_name} #{td_class}"
      end

      it "#{feature_name}の値が表示されていること" do
        is_asserted_by do
          @tbody.search('td')[i].text.strip == @test_datum.feature[feature_name].to_s
        end
      end
    end
  end

  before do
    render template: 'evaluation/races/show', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '1着と予測した場合' do
    include_context 'トランザクション作成'
    include_context '評価テストデータを作成する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'テストデータが正しく表示されていること', td_class: 'table-success'
  end

  context '1着でないと予測した場合' do
    include_context 'トランザクション作成'
    include_context '評価テストデータを作成する', prediction_result: false
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'テストデータが正しく表示されていること', td_class: 'table-danger'
  end
end

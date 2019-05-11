# coding: utf-8

require 'rails_helper'

describe 'predictions/manage', type: :view do
  per_page = 1
  default_attribute = {model: 'model', test_data: 'test_data', state: 'processing'}

  shared_context '予測ジョブを作成する' do |total: per_page, attribute: {}, results: 0|
    before(:all) do
      total.times do
        prediction = Prediction.create!(attribute)
        results.times {|i| prediction.results.create!(number: i + 1) }
      end
      @predictions = Prediction.order(created_at: :desc).page(1)
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
      title = @html.xpath("#{form_panel_xpath}/div[@id='new-prediction']/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text == 'レースを予測' }
    end

    it 'テストデータへのリンクが表示されていること' do
      link = @html.xpath("#{form_panel_xpath}/div[@id='new-prediction']/p" \
                         '/a[@href="http://db.netkeiba.com"]')
      is_asserted_by { link.present? }
      is_asserted_by { link.text == 'こちら' }
    end

    %w[model test_data].each do |param|
      it "prediction_#{param}を含む<label>タグがあること" do
        label =
          @html.xpath("#{input_xpath('prediction')}/label[@for='prediction_#{param}']")
        is_asserted_by { label.present? }
      end

      it "prediction_#{param}を含む<input>タグがあること" do
        input =
          @html.xpath("#{input_xpath('prediction')}/label[@for='prediction_#{param}']")
        is_asserted_by { input.present? }
      end
    end

    %w[file url].each do |type|
      it "#{type}を選択するラジオボタンがあること" do
        radio_button =
          @html.xpath("#{input_xpath('prediction')}/label/input[@id='type_#{type}']")
        is_asserted_by { radio_button.present? }
      end
    end

    it 'ファイルが選択状態になっていること' do
      input = @html.xpath("#{input_xpath('prediction')}/label/input[@id='type_file']" \
                          '[@checked]')
      is_asserted_by { input.present? }
    end

    %w[submit reset].each do |type|
      it "typeが#{type}のボタンがあること" do
        button = @html.xpath("#{form_xpath('prediction')}/input[@type='#{type}']")
        is_asserted_by { button.present? }
      end
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 0|
    before(:each) do
      @table = @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']")
    end

    it '4列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 4 }
    end

    %w[実行開始日時 モデル テストデータ 予測結果].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples 'テストデータがリンクになっていること' do
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      @predictions.each_with_index do |prediction, i|
        test_data = rows.xpath('//td[@class="td-test-data"]')[i]

        link = test_data.xpath("//a[@href='#{prediction.test_data}']")
        is_asserted_by { link.present? }

        icon = link.xpath('//span[@class="glyphicon glyphicon-new-window"]')
        is_asserted_by { icon.present? }
      end
    end
  end

  shared_examples 'ジョブが実行中状態になっていること' do
    it do
      rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")

      @predictions.each_with_index do |_, i|
        test_data = rows.xpath('//td[@class="td-result"]')[i]
        is_asserted_by { test_data.search('span').text == '実行中' }
        is_asserted_by { test_data.search('i[@class="fa fa-refresh fa-spin"]').present? }
      end
    end
  end

  shared_examples 'テーブルに予測結果が表示されていること' do |numbers: 0|
    color = %w[orange skyblue magenta]

    before(:each) do
      @result = [
        table_panel_xpath,
        'table[@class="table table-hover"]',
        'tbody',
        'tr',
        'td[@class="td-result"]',
      ].join('/')
    end

    it 'タイトルが表示されること' do
      results = @html.xpath(@result)

      @predictions.each_with_index do |prediction, i|
        title = prediction.results.map(&:number).sort.join(',')
        is_asserted_by { results[i].search("span[@title='#{title}']").present? }
      end
    end

    it '番号が正しく表示されていること' do
      results = @html.xpath(@result)

      @predictions.each_with_index do |prediction, i|
        results[i].search('span[@class="fa-stack"]').each_with_index do |result, j|
          is_asserted_by do
            result.attribute('style').value.include?(color[j] || 'black')
          end

          circle = result.children.search('i[@class="fa fa-circle fa-stack-2x"]')
          is_asserted_by { circle.present? }

          numbers = prediction.results.map(&:number).sort
          number = result.children.search('i[@class="fa fa-stack-1x fa-inverse"]')
          is_asserted_by { number.present? }
          is_asserted_by { number.text == numbers[j].to_s }
        end
      end
    end

    it '3点リーダが表示されていないこと', if: numbers <= 6 do
      @html.xpath(@result).each do |result|
        is_asserted_by do
          result.children.search('span').none? {|span| span.text.strip == '...' }
        end
      end
    end

    it '3点リーダが表示されていること', if: numbers > 6 do
      @html.xpath(@result).each do |result|
        is_asserted_by { result.children.search('span').last.text == '...' }
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @prediction = Prediction.new
  end

  before(:each) do
    render template: 'predictions/manage', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '実行中の場合' do
    attribute = default_attribute.merge(test_data: 'https://db.netkeiba.com/race/123456')
    include_context 'トランザクション作成'
    include_context '予測ジョブを作成する', attribute: attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like 'テストデータがリンクになっていること'
    it_behaves_like 'ジョブが実行中状態になっていること'
  end

  context '完了している場合' do
    attribute = default_attribute.merge(state: 'completed')

    context '番号の数が6個の場合' do
      include_context 'トランザクション作成'
      include_context '予測ジョブを作成する', attribute: attribute, results: 6
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'テーブルに予測結果が表示されていること', numbers: 6
    end

    context '番号の数が7個の場合' do
      include_context 'トランザクション作成'
      include_context '予測ジョブを作成する', attribute: attribute, results: 7
      include_context 'HTML初期化'
      it_behaves_like '画面共通テスト'
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like 'テーブルに予測結果が表示されていること', numbers: 7
    end
  end

  describe "予測ジョブ情報が#{per_page * (Kaminari.config.window + 2)}件の場合" do
    total = per_page * (Kaminari.config.window + 2)
    include_context 'トランザクション作成'
    include_context '予測ジョブを作成する', total: total, attribute: default_attribute
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト', expected: {total: total}
    it_behaves_like 'ページングボタンが表示されていること', model: 'prediction'
  end
end

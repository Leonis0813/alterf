# -*- coding: utf-8 -*-

shared_context '予測ジョブを作成する' do |total: nil, update_attribute: {}, results: 0|
  default_attribute = {model: 'model', test_data: 'test_data'}

  before(:all) do
    attribute = default_attribute.merge(update_attribute)
    total ||= PredictionViewHelper::DEFAULT_PER_PAGE
    total.times do
      prediction = create(:prediction, attribute)
      (1..18).each do |i|
        prediction.results.create!(number: i, won: i <= results)
      end
    end
    @predictions = Prediction.order(created_at: :desc).page(1)
  end
end

shared_examples '予測画面共通テスト' do |expected: {}|
  it_behaves_like 'ヘッダーが表示されていること'
  it_behaves_like '予測情報入力フォームが表示されていること'
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || PredictionViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || PredictionViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '予測ジョブテーブルが表示されていること',
                  rows: expected[:rows] || PredictionViewHelper::DEFAULT_PER_PAGE
end

shared_examples '予測情報入力フォームが表示されていること' do
  it_behaves_like 'タイトルが表示されていること', 'レースを予測'

  it 'テストデータへのリンクが表示されていること' do
    link = @html.xpath("#{form_panel_xpath}/p/a[@href='http://db.netkeiba.com']")
    is_asserted_by { link.present? }
    is_asserted_by { link.text == 'こちら' }
  end

  %w[model test_data].each do |param|
    it "prediction_#{param}を含む<label>タグがあること" do
      label = @html.xpath("#{input_xpath}/label[@for='prediction_#{param}']")
      is_asserted_by { label.present? }
    end

    it "prediction_#{param}を含む<input>タグがあること" do
      input = @html.xpath("#{input_xpath}/label[@for='prediction_#{param}']")
      is_asserted_by { input.present? }
    end
  end

  %w[file url].each do |type|
    it "#{type}を選択するラジオボタンがあること" do
      radio_button = @html.xpath("#{input_xpath}/label/input[@id='type_#{type}']")
      is_asserted_by { radio_button.present? }
    end
  end

  it 'ファイルが選択状態になっていること' do
    input = @html.xpath("#{input_xpath}/label/input[@id='type_file'][@checked]")
    is_asserted_by { input.present? }
  end

  %w[submit reset].each do |type|
    it "typeが#{type}のボタンがあること" do
      button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
      is_asserted_by { button.present? }
    end
  end
end

shared_examples '予測ジョブテーブルが表示されていること' do |rows: 0|
  before { @table = @html.xpath(table_xpath) }

  it '4列のテーブルが表示されていること' do
    is_asserted_by { @table.search('thead/th').size == 4 }
  end

  %w[実行開始日時 モデル テストデータ 予測結果].each_with_index do |text, i|
    it "#{i + 1}列目のヘッダーが#{text}であること" do
      is_asserted_by { @table.search('thead/th')[i].text == text }
    end
  end

  it 'ジョブの数が正しいこと' do
    is_asserted_by { @table.search('tbody/tr').size == rows }
  end
end

shared_examples 'テストデータがリンクになっていること' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @predictions.each_with_index do |prediction, i|
      test_data = rows[i].search('td[@class="td-test-data"]')

      link = test_data.search("a[@href='#{prediction.test_data}']")
      is_asserted_by { link.present? }

      icon = link.search('span[@class="glyphicon glyphicon-new-window new-window"]')
      is_asserted_by { icon.present? }
    end
  end
end

shared_examples 'ジョブが実行待ち状態になっていること' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @predictions.each_with_index do |_, i|
      test_data = rows[i].search('td[@class="td-result"]')
      is_asserted_by { test_data.search('span').text == '実行待ち' }
    end
  end
end

shared_examples 'ジョブが実行中状態になっていること' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @predictions.each_with_index do |_, i|
      test_data = rows[i].search('td[@class="td-result"]')
      is_asserted_by { test_data.search('span').text == '実行中' }
      is_asserted_by { test_data.search('i[@class="fa fa-refresh fa-spin"]').present? }
    end
  end
end

shared_examples 'ジョブがエラー状態になっていること' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @predictions.each_with_index do |_, i|
      error_span = rows[i].search('td[@class="td-result"]')
                          .search('span[@class="glyphicon glyphicon-remove"]')
      is_asserted_by { error_span.present? }
    end
  end
end

shared_examples 'テーブルに予測結果が表示されていること' do |numbers: 0|
  color = %w[orange skyblue magenta]

  before do
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
      title = prediction.results.won.map(&:number).sort.join(',')
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

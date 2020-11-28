# -*- coding: utf-8 -*-

shared_context '評価ジョブを作成する' do |total: nil, update_attribute: {}|
  before(:all) do
    total ||= EvaluationViewHelper::DEFAULT_PER_PAGE
    total.times do |i|
      attribute = {evaluation_id: i.to_s * 32}.merge(update_attribute)
      evaluation = create(:evaluation, attribute)
      evaluation.data.create!(
        race_id: '1' * 8,
        race_name: 'race_name',
        race_url: 'race_url',
        ground_truth: 1,
      )
    end
    @evaluations = Evaluation.order(created_at: :desc).page(1)
  end
end

shared_examples '評価画面共通テスト' do |expected: {}|
  it_behaves_like 'ヘッダーが表示されていること'
  it_behaves_like '評価情報入力フォームが表示されていること'
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || EvaluationViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || EvaluationViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '評価ジョブテーブルが表示されていること',
                  rows: expected[:rows] || EvaluationViewHelper::DEFAULT_PER_PAGE
end

shared_examples '評価情報入力フォームが表示されていること' do
  it 'タイトルが表示されていること' do
    title = @html.xpath("#{form_panel_xpath}/h3")
    is_asserted_by { title.present? }
    is_asserted_by { title.text == 'モデルを評価' }
  end

  %w[model data].each do |param|
    it "evaluation_#{param}を含む<label>タグがあること" do
      label =
        @html.xpath("#{input_xpath}/label[@for='evaluation_#{param}']")
      is_asserted_by { label.present? }
    end
  end

  it 'evaluation_modelを含む<input>タグがあること' do
    input =
      @html.xpath("#{input_xpath}/input[@id='evaluation_model']")
    is_asserted_by { input.present? }
  end

  it 'data_sourceを含む<label>タグがあること' do
    xpath = "#{input_xpath}/span/label[@for='data_source']"
    is_asserted_by { @html.xpath(xpath).present? }
  end

  it 'data_sourceを含む<select>タグがあること' do
    xpath = "#{input_xpath}/span/select[@id='data_source']"
    is_asserted_by { @html.xpath(xpath).present? }
  end

  [
    %w[remote Top20],
    %w[file ファイル],
    %w[text 直接入力],
    %w[random ランダム],
  ].each do |value, text|
    it "valueが#{value}の<option>タグがあること" do
      xpath = "#{input_xpath}/span/select[@id='data_source']/option[@value='#{value}']"
      is_asserted_by { @html.xpath(xpath).present? }
      is_asserted_by { @html.xpath(xpath).text == text }
    end
  end

  it '非表示で無効になっているファイル入力フォームがあること' do
    xpath = "#{input_xpath}/input[@id='evaluation_data_file']" \
            "[@class='form-control form-data-source not-selected'][@disabled]"
    is_asserted_by { @html.xpath(xpath).present? }
  end

  it '非表示で無効になっているテキスト入力フォームがあること' do
    xpath = "#{input_xpath}/textarea[@id='evaluation_data_text']" \
            "[@class='form-control form-data-source not-selected'][@disabled]"
    is_asserted_by { @html.xpath(xpath).present? }
  end

  it '非表示で無効になっているデータ数入力フォームがあること' do
    xpath = "#{input_xpath}/input[@id='evaluation_data_random']" \
            "[@class='form-control form-data-source not-selected'][@disabled]"
    is_asserted_by { @html.xpath(xpath).present? }
  end

  %w[submit reset].each do |type|
    it "typeが#{type}のボタンがあること" do
      button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
      is_asserted_by { button.present? }
    end
  end
end

shared_examples '評価ジョブテーブルが表示されていること' do |rows: 0|
  before { @table = @html.xpath(table_xpath) }

  it '7列のテーブルが表示されていること' do
    is_asserted_by { @table.search('thead/th').size == 7 }
  end

  %w[実行開始日時 モデル 状態 適合率 再現率 F値].each_with_index do |text, i|
    it "#{i + 1}列目のヘッダーが#{text}であること" do
      is_asserted_by { @table.search('thead/th')[i].text == text }
    end
  end

  it 'ジョブの数が正しいこと' do
    is_asserted_by { @table.search('tbody/tr').size == rows }
  end
end

shared_examples '実行開始時間が表示されていないこと' do
  it do
    @html.xpath("#{table_xpath}/tbody/tr").each do |row|
      is_asserted_by { row.search('td')[0].text.strip.blank? }
    end
  end
end

shared_examples 'ジョブの状態が正しいこと' do |state: nil, button_class: nil|
  before { @rows = @html.xpath("#{table_xpath}/tbody/tr") }

  it do
    @evaluations.size.times do |i|
      is_asserted_by { @rows[i].search('td')[2].text.strip == state }
    end
  end

  it '詳細ボタンになっていること', unless: %w[実行待ち エラー].include?(state) do
    @evaluations.each_with_index do |evaluation, i|
      button_xpath = "a[@href='/evaluations/#{evaluation.evaluation_id}']" \
                     "/button[@class='btn btn-xs btn-#{button_class}']"
      button = @rows[i].search('td')[2].children.search(button_xpath)
      is_asserted_by { button.present? }
    end
  end
end

shared_examples '評価結果情報が表示されていること' do
  before { @rows = @html.xpath("#{table_xpath}/tbody/tr") }

  it '適合率が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      precision = @rows[i].children.search('td')[3]
      is_asserted_by { precision.text.strip == evaluation.precision.round(3).to_s }
    end
  end

  it '再現率が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      precision = @rows[i].children.search('td')[4]
      is_asserted_by { precision.text.strip == evaluation.recall.round(3).to_s }
    end
  end

  it 'F値が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      precision = @rows[i].children.search('td')[5]
      is_asserted_by { precision.text.strip == evaluation.f_measure.round(3).to_s }
    end
  end
end

shared_examples 'ダウンロードボタンが表示されていないこと' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @evaluations.each_with_index do |evaluation, i|
      download_button = rows[i].children.search('td')[6]
      link_xpath = "a[@href='/evaluations/#{evaluation.evaluation_id}/download']" \
                   '/button[@class="btn btn-success"]' \
                   '/span[@class="glyphicon glyphicon-download-alt"]'
      is_asserted_by { download_button.children.search(link_xpath).blank? }
    end
  end
end

shared_examples 'ダウンロードボタンが表示されていること' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @evaluations.each_with_index do |evaluation, i|
      download_button = rows[i].children.search('td')[6]
      link_xpath = "a[@href='/evaluations/#{evaluation.evaluation_id}/download']" \
                   '/button[@class="btn btn-success"]' \
                   '/span[@class="glyphicon glyphicon-download-alt"]'
      is_asserted_by { download_button.children.search(link_xpath).present? }
    end
  end
end

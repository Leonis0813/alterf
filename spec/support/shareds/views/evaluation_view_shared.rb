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
  it_behaves_like '入力フォーム用のタブが表示されていること'
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || EvaluationViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || EvaluationViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '評価ジョブテーブルが表示されていること',
                  rows: expected[:rows] || EvaluationViewHelper::DEFAULT_PER_PAGE
end

shared_examples '入力フォーム用のタブが表示されていること' do
  it '表示切り替え用のタブが表示されていること' do
    xpath = [
      form_tab_xpath,
      'li[@class="nav-item"]',
      'button[@id="collapse-form"]',
    ].join('/')
    collapse = @html.xpath(xpath)
    is_asserted_by { collapse.present? }
  end

  it 'ジョブ登録用のタブが表示されていること' do
    xpath = [
      form_tab_xpath,
      'li[@class="nav-item active"]',
      'button[@id="tab-register"][@class="nav-link active"]' \
      '[@data-bs-target="#new-evaluation"]',
    ].join('/')
    tab_register = @html.xpath(xpath)
    is_asserted_by { tab_register.present? }
    is_asserted_by { tab_register.text.strip == 'ジョブ登録' }
  end

  it_behaves_like 'ジョブ登録フォームが表示されていること'
end

shared_examples 'ジョブ登録フォームが表示されていること' do
  [
    %w[evaluation_model モデル],
    %w[evaluation_data 評価データ],
    %w[data_source 指定方法:],
  ].each do |param, text|
    it "フォームのラベルが表示されていること(ラベル: #{text})" do
      label = @html.xpath("#{input_xpath}/label[@for='#{param}']")
      is_asserted_by { label.present? }
      is_asserted_by { label.text.strip == text }
    end
  end

  it 'モデル入力フォームが表示されていること' do
    input = @html.xpath("#{input_xpath}/input[@id='evaluation_model']")
    is_asserted_by { input.present? }
  end

  it '指定方法を選択するセレクトボックスが表示されていること' do
    select = @html.xpath("#{input_xpath}/select[@id='evaluation_data_source']")
    is_asserted_by { select.present? }
  end

  [
    %w[remote Top20],
    %w[file ファイル],
    %w[text 直接入力],
    %w[random ランダム],
  ].each do |value, text|
    it "指定方法として#{text}が選択できること" do
      xpath = "#{input_xpath}/select[@id='evaluation_data_source']" \
              "/option[@value='#{value}']"
      option = @html.xpath(xpath)
      is_asserted_by { option.present? }
      is_asserted_by { option.text.strip == text }
    end
  end

  [
    %w[file input ファイル],
    %w[text textarea テキスト],
    %w[random input データ数],
  ].each do |id, tag, desc|
    it "非表示で無効になっている#{desc}入力フォームがあること" do
      xpath = [
        input_xpath,
        "#{tag}[@id='evaluation_data_#{id}'][@disabled]" \
        '[@class="form-control form-data-source not-selected"][@disabled]',
      ].join('/')
      form = @html.xpath(xpath)
      is_asserted_by { form.present? }
    end
  end

  [
    %w[submit 実行],
    %w[reset リセット],
  ].each do |type, value|
    it "typeが#{type}のボタンがあること" do
      xpath = [
        form_xpath,
        'div[@class="row text-end"]',
        'div[@class="col-12"]',
        "input[@type='#{type}']",
      ].join('/')
      button = @html.xpath(xpath)
      is_asserted_by { button.present? }
      is_asserted_by { button.attribute('value').value == value }
    end
  end
end

shared_examples '評価ジョブテーブルが表示されていること' do |rows: 0|
  before { @table = @html.xpath(table_xpath) }

  it '10列のテーブルが表示されていること' do
    is_asserted_by { @table.search('thead/th').size == 10 }
  end

  %w[
    実行開始日時
    モデル
    指定方法
    データ数
    状態
    適合率
    再現率
    特異度
    F値
  ].each_with_index do |text, i|
    it "#{i + 1}列目のヘッダーが#{text}であること" do
      is_asserted_by { @table.search('thead/th')[i].text == text }
    end
  end

  it 'ジョブの数が正しいこと' do
    is_asserted_by { @table.search('tbody/tr').size == rows }
  end
end

shared_examples 'テーブルの列がリンクになっていないこと' do
  it do
    @html.xpath("#{table_xpath}/tbody/tr").each do |row|
      is_asserted_by { row.attribute('class').value.include?('cursor-auto') }
      is_asserted_by { row.attribute('title').value.empty? }
    end
  end
end

shared_examples 'テーブルの列がリンクになっていること' do
  it do
    @html.xpath("#{table_xpath}/tbody/tr").each do |row|
      is_asserted_by { row.attribute('class').value.include?('cursor-pointer') }
      is_asserted_by { row.attribute('title').value.include?('結果を確認') }
    end
  end
end

shared_examples '実行開始時間が表示されていないこと' do
  it do
    @html.xpath("#{table_xpath}/tbody/tr").each do |row|
      is_asserted_by { row.search('td')[0].text.strip.blank? }
    end
  end
end

shared_examples '評価ジョブの情報が表示されていること' do |state: nil|
  before { @rows = @html.xpath("#{table_xpath}/tbody/tr") }

  it 'モデルが表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      model = @rows[i].search('td')[1].text.strip
      is_asserted_by { model == evaluation.model }
    end
  end

  it '指定方法が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      data_source = @rows[i].search('td')[2].text.strip
      is_asserted_by { data_source == data_source_map[evaluation.data_source] }
    end
  end

  it 'データ数が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      data_size = @rows[i].search('td')[3].text.strip
      is_asserted_by { data_size == evaluation.num_data.to_s }
    end
  end

  it '状態が表示されていること' do
    @evaluations.size.times do |i|
      is_asserted_by { @rows[i].search('td')[4].text.strip == state }
    end
  end
end

shared_examples '評価結果情報が表示されていること' do
  before { @rows = @html.xpath("#{table_xpath}/tbody/tr") }

  it '適合率が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      precision = @rows[i].children.search('td')[5]
      is_asserted_by { precision.text.strip == evaluation.precision.round(3).to_s }
    end
  end

  it '再現率が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      recall = @rows[i].children.search('td')[6]
      is_asserted_by { recall.text.strip == evaluation.recall.round(3).to_s }
    end
  end

  it '特異度が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      specificity = @rows[i].children.search('td')[7]
      is_asserted_by { specificity.text.strip == evaluation.specificity.round(3).to_s }
    end
  end

  it 'F値が表示されていること' do
    @evaluations.each_with_index do |evaluation, i|
      f_measure = @rows[i].children.search('td')[8]
      is_asserted_by { f_measure.text.strip == evaluation.f_measure.round(3).to_s }
    end
  end
end

shared_examples 'ダウンロードボタンが表示されていないこと' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @evaluations.each_with_index do |evaluation, i|
      download_button = rows[i].children.search('td')[9]
      download_link = download_button.search(download_link_xpath(evaluation))
      is_asserted_by { download_link.blank? }
    end
  end
end

shared_examples 'ダウンロードボタンが表示されていること' do
  it do
    rows = @html.xpath("#{table_xpath}/tbody/tr")

    @evaluations.each_with_index do |evaluation, i|
      download_button = rows[i].children.search('td')[9]
      download_link = download_button.search(download_link_xpath(evaluation))
      is_asserted_by { download_link.present? }
    end
  end
end

# -*- coding: utf-8 -*-

shared_context '分析ジョブを作成する' do |total: nil, update_attribute: {}|
  default_attribute = {num_data: 10000}

  before(:all) do
    attribute = default_attribute.merge(update_attribute)
    total ||= AnalysisViewHelper::DEFAULT_PER_PAGE
    total.times {|i| create(:analysis, attribute.merge(analysis_id: i.to_s * 32)) }
    @analyses = Analysis.order(created_at: :desc).page(1)
  end
end

shared_context '分析フォームオブジェクトを作成する' do |attribute = {}|
  before(:all) do
    @new_analysis = Analysis.new
    @new_analysis.build_parameter
    @index_form = Analyses::IndexForm.new(attribute)
  end
end

shared_examples '分析画面共通テスト' do |expected: {}|
  it_behaves_like 'ヘッダーが表示されていること'
  it_behaves_like '分析情報入力フォームが表示されていること'
  it_behaves_like '表示件数情報が表示されていること',
                  total: expected[:total] || AnalysisViewHelper::DEFAULT_PER_PAGE,
                  from: expected[:from] || 1,
                  to: expected[:to] || AnalysisViewHelper::DEFAULT_PER_PAGE
  it_behaves_like '分析ジョブテーブルが表示されていること',
                  rows: expected[:rows] || AnalysisViewHelper::DEFAULT_PER_PAGE
end

shared_examples '分析情報入力フォームが表示されていること' do
  [
    %w[登録 new-analysis],
    %w[検索 search-form],
  ].each do |tab_name, tab_id|
    it "#{tab_name}タブが表示されていること" do
      xpath = [
        form_tab_xpath,
        'li[@class="nav-item"]',
        "button[contains(@class, 'nav-link')][@data-bs-target='##{tab_id}']",
      ].join('/')
      tab = @html.xpath(xpath)
      is_asserted_by { tab.present? }
      is_asserted_by { tab.text.strip == tab_name }
    end
  end

  it '分析ジョブ登録フォームがアクティブになっていること' do
    xpath = [
      form_tab_xpath,
      'li[@class="nav-item"]',
      'button[@class="nav-link active"][@data-bs-target="#new-analysis"]',
    ].join('/')
    tab = @html.xpath(xpath)
    is_asserted_by { tab.present? }
  end

  it_behaves_like '分析ジョブ登録フォームが表示されていること'
  it_behaves_like '分析ジョブ検索フォームが表示されていること'
end

shared_examples '分析ジョブ登録フォームが表示されていること' do
  it 'タイトルが表示されていること' do
    title = @html.xpath("#{register_form_panel_xpath}/h4")
    is_asserted_by { title.present? }
    is_asserted_by { title.text.strip == 'レースを分析' }
  end

  it '必須項目の説明が表示されていること' do
    description = @html.xpath("#{register_form_panel_xpath}/h5")
    is_asserted_by { description.present? }
    is_asserted_by { description.text.strip == '* は必須項目です' }
  end

  [
    %w[analysis_data 学習データ],
    %w[data_source 指定方法:],
  ].each do |param_name, label_name|
    it "入力フォームのラベルがあること(ラベル: #{label_name})" do
      label = @html.xpath("#{register_input_xpath}/label[@for='#{param_name}']")
      is_asserted_by { label.present? }
      is_asserted_by { label.text.strip == label_name }
    end
  end

  it '指定方法を選択するセレクトボックスが表示されていること' do
    select = @html.xpath("#{register_input_xpath}/select[@id='analysis_data_source']")
    is_asserted_by { select.present? }
  end

  [
    %w[random ランダム],
    %w[file ファイル],
  ].each do |value, text|
    it "指定方法として#{text}が選択できること" do
      xpath = "#{register_input_xpath}/select[@id='analysis_data_source']" \
              "/option[@value='#{value}']"
      option = @html.xpath(xpath)
      is_asserted_by { option.present? }
      is_asserted_by { option.text.strip == text }
    end
  end

  it 'データ数入力フォームのラベルが表示されていること' do
    xpath = "#{register_input_xpath}/div[@class='form-block-data-source']" \
            '/label[@for="analysis_data_random"]'
    label = @html.xpath(xpath)

    is_asserted_by { label.present? }
    is_asserted_by { label.text.strip == 'データ数' }
  end

  it 'データ数入力フォームが表示されていること' do
    xpath = "#{register_input_xpath}/div[@class='form-block-data-source']" \
            '/input[@id="analysis_data_random"][@name="num_data"]'
    input = @html.xpath(xpath)
    is_asserted_by { input.present? }
  end

  it '非表示で無効になっているファイル入力フォームがあること' do
    xpath = "#{register_input_xpath}/div[@class='form-block-data-source not-selected']" \
            '/input[@id="analysis_data_file"][@name="data_file"][@disabled]'
    input = @html.xpath(xpath)
    is_asserted_by { input.present? }
  end

  it 'パラメーター入力フォームが表示されていること' do
    xpath = "#{register_input_xpath}/div[@id='label-register-parameter']"
    input = @html.xpath(xpath)
    is_asserted_by { input.present? }
    is_asserted_by { input.text.strip == 'パラメーター' }
  end

  [
    ['max_depth', nil],
    ['max_leaf_nodes', nil],
    %w[min_samples_leaf 1],
    %w[min_samples_split 2],
    %w[num_tree 100],
  ].each do |param_name, value|
    it "#{param_name}入力フォームがあること" do
      parameter_form = @html.xpath(register_parameter_form_xpath)

      form_id = "analysis_parameter_attributes_#{param_name}"
      label = parameter_form.search("label[@for='#{form_id}']")
      is_asserted_by { label.present? }
      is_asserted_by { label.text.strip == param_name }

      input = parameter_form.search("input[@id='#{form_id}']")
      is_asserted_by { input.present? }
      is_asserted_by { input.attribute('value')&.value == value }
    end
  end

  it 'max_features入力フォームがあること' do
    parameter_form = @html.xpath(register_parameter_form_xpath)

    form_id = 'analysis_parameter_attributes_max_features'
    label = parameter_form.search("label[@for='#{form_id}']")
    is_asserted_by { label.present? }
    is_asserted_by { label.text == 'max_features' }

    select = parameter_form.search("select[@id='#{form_id}']")
    is_asserted_by { select.present? }

    %w[sqrt log2 all].each do |value|
      is_asserted_by { select.search("option[@value='#{value}']").present? }
    end

    is_asserted_by do
      select.search('option[@value="sqrt"][@selected="selected"]').present?
    end
  end

  [
    %w[submit 実行],
    %w[reset リセット],
  ].each do |type, value|
    it "#{value}ボタンがあること" do
      button = @html.xpath("#{register_form_xpath}/input[@type='#{type}']")
      is_asserted_by { button.present? }
      is_asserted_by { button.attribute('value').value == value }
    end
  end
end

shared_examples '分析ジョブ検索フォームが表示されていること' do
  it 'タイトルが表示されていること' do
    title = @html.xpath("#{index_form_panel_xpath}/h4[@class='card-title']")
    is_asserted_by { title.present? }
    is_asserted_by { title.text.strip == 'ジョブを検索' }
  end

  it '学習データ数入力フォームのラベルがあること' do
    label = @html.xpath("#{index_input_xpath}/label[@for='input-index-num_data']")
    is_asserted_by { label.present? }
    is_asserted_by { label.text.strip == '学習データ数' }
  end

  it '学習データ数入力フォームがあること' do
    input = @html.xpath("#{index_input_xpath}/input[@id='input-index-num_data']")
    is_asserted_by { input.present? }
    is_asserted_by { input.attribute('value')&.value&.to_i == @index_form.num_data }
  end

  it 'パラメーター入力ラベルが表示されていること' do
    label = @html.xpath("#{index_form_xpath}/div[@id='label-index-parameter']")
    is_asserted_by { label.present? }
    is_asserted_by { label.text.strip == 'パラメーター' }
  end

  %w[
    max_depth
    max_leaf_nodes
    min_samples_leaf
    min_samples_split
    num_tree
  ].each do |param_name|
    it "#{param_name}入力フォームがあること" do
      form_id = "input-index-#{param_name}"
      label = @html.xpath("#{index_parameter_form_xpath}/label[@for='#{form_id}']")
      is_asserted_by { label.present? }
      is_asserted_by { label.text.strip == param_name }

      input = @html.xpath("#{index_parameter_form_xpath}/input[@id='#{form_id}']")
      is_asserted_by { input.present? }
      is_asserted_by do
        input.attribute('value')&.value&.to_i == @index_form.parameter[param_name]
      end
    end
  end

  it 'max_features入力フォームがあること' do
    form_id = 'input-index-max_features'
    label = @html.xpath("#{index_parameter_form_xpath}/label[@for='#{form_id}']")
    is_asserted_by { label.present? }
    is_asserted_by { label.text.strip == 'max_features' }

    select = @html.xpath("#{index_parameter_form_xpath}/select[@id='#{form_id}']")
    is_asserted_by { select.present? }

    %w[sqrt log2 all].each do |value|
      is_asserted_by { select.search("option[@value='#{value}']").present? }
    end

    selected = select.search('option[@selected="selected"]')
    is_asserted_by do
      selected.attribute('value')&.value == @index_form.parameter[:max_features]
    end
  end

  it '検索ボタンがあること' do
    button = @html.xpath("#{index_form_xpath}/input[@type='submit']")
    is_asserted_by { button.present? }
    is_asserted_by { button.attribute('value').value == '検索' }
  end
end

shared_examples '分析ジョブテーブルが表示されていること' do |rows: 0|
  before do
    @table = @html.xpath(table_xpath)
    @rows = @table.search('tbody/tr')
  end

  it '8列のテーブルが表示されていること' do
    is_asserted_by { @table.search('thead/th').size == 8 }
  end

  %w[
    実行開始日時
    指定方法
    学習データ数
    特徴量の数
    パラメーター
    状態
  ].each_with_index do |text, i|
    it "#{i + 1}列目のヘッダーが#{text}であること" do
      is_asserted_by { @table.search('thead/th')[i].text == text }
    end
  end

  it 'ダウンロードボタンが配置されている列があること' do
    is_asserted_by { @table.search('thead/th[@class="download"]').present? }
  end

  it '再実行ボタンが配置されている列があること' do
    is_asserted_by { @table.search('thead/th[@class="rebuild"]').present? }
  end

  it 'ジョブの数が正しいこと' do
    is_asserted_by { @rows.size == rows }
  end

  it 'ジョブ情報が正しく表示されていること' do
    @analyses.each_with_index do |analysis, i|
      performed_at = analysis.performed_at&.strftime('%Y/%m/%d %T')
      tds = @rows[i].search('td')
      is_asserted_by { tds[0].text.strip == performed_at.to_s }
      is_asserted_by { tds[1].text.strip == data_source_map[analysis.data_source] }
      is_asserted_by { tds[2].text.strip == analysis.num_data.to_s }
      is_asserted_by { tds[3].text.strip == analysis.num_feature.to_s }
      is_asserted_by { tds[5].text.strip == state_map[analysis.state] }
    end
  end

  it 'パラメーター表示ボタンが表示されていること' do
    @rows.each do |row|
      button = row.search('td')[4].search('button')
      is_asserted_by { button.present? }
      is_asserted_by { button.text.strip == '確認' }
    end
  end

  it '再実行ボタンが表示されていること' do
    @analyses.each_with_index do |analysis, i|
      rebuild_form = @rows[i].search('td')[7].search('form')
      is_asserted_by { rebuild_form.present? }

      expected_action = "/analyses/#{analysis.analysis_id}/rebuild"
      is_asserted_by { rebuild_form.attr('action').value == expected_action }
    end
  end
end

shared_examples '分析ジョブの状態が正しいこと' do |state, num_entry: 0|
  before { @rows = @html.xpath(table_xpath).search('tbody/tr') }

  it do
    @rows.each do |row|
      is_asserted_by { row.search('td')[5].text.strip == state }
    end
  end

  it '実行中の場合はアイコンが表示されていること', if: state == '実行中' do
    @rows.each do |row|
      td_children = row.search('td')[5].children

      is_asserted_by { td_children.search('span[@class="processing"]').present? }

      is_asserted_by do
        td_children.search('i[@class="fas fa-sync-alt fa-spin"]').present?
      end
    end
  end

  it '完了の場合は結果画面へのボタンが表示されていること', if: state == '完了' do
    @rows.each do |row|
      result_button = row.search('td')[5].search(result_button_xpath)
      is_asserted_by { result_button.present? }
    end
  end

  it '完了の場合はダウンロードボタンが表示されていること', if: state == '完了' do
    @rows.each do |row|
      download_link = row.search('td')[6].search(download_link_xpath)
      is_asserted_by { download_link.present? }
    end
  end
end

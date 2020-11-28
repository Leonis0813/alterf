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
  it_behaves_like 'タイトルが表示されていること', 'レースを分析'

  it '必須項目の説明が表示されていること' do
    description = @html.xpath("#{form_panel_xpath}/h4")
    is_asserted_by { description.present? }
    is_asserted_by { description.text.strip == '* は必須項目です' }
  end

  [
    ['num_data', '学習データ数'],
    ['num_entry', 'エントリー数'],
  ].each do |param_name, label_name|
    it "#{label_name}入力フォームのラベルがあること" do
      label = @html.xpath("#{input_xpath}/label[@for='analysis_#{param_name}']")
      is_asserted_by { label.present? }
      is_asserted_by { label.text == label_name }
    end

    it "#{label_name}入力フォームがあること" do
      input = @html.xpath("#{input_xpath}/input[@id='analysis_#{param_name}']")
      is_asserted_by { input.present? }
      is_asserted_by { input.attribute('value').nil? }
    end
  end

  it 'パラメーター入力フォームが閉じた状態で表示されていること' do
    parameter_form_link = @html.xpath(input_xpath).search('a[@href="#parameter"]')
    is_asserted_by { parameter_form_link.present? }
    is_asserted_by { parameter_form_link.text.strip == 'パラメーター設定' }

    parameter_form_block = @html.xpath(form_xpath).search('div[@class="collapse"]')
    is_asserted_by { parameter_form_block.present? }
  end

  [
    ['max_depth', nil],
    ['max_leaf_nodes', nil],
    %w[min_samples_leaf 1],
    %w[min_samples_split 2],
    %w[num_tree 100],
  ].each do |param_name, value|
    it "#{param_name}入力フォームがあること" do
      parameter_form_block = @html.xpath(parameter_form_block_xpath)

      form_id = "analysis_parameter_attributes_#{param_name}"
      label = parameter_form_block.search("label[@for='#{form_id}']")
      is_asserted_by { label.present? }
      is_asserted_by { label.text == param_name }

      input = parameter_form_block.search("input[@id='#{form_id}']")
      is_asserted_by { input.present? }
      is_asserted_by { input.attribute('value')&.value == value }
    end
  end

  it 'max_features入力フォームがあること' do
    parameter_form_block = @html.xpath(parameter_form_block_xpath)

    form_id = 'analysis_parameter_attributes_max_features'
    label = parameter_form_block.search("label[@for='#{form_id}']")
    is_asserted_by { label.present? }
    is_asserted_by { label.text == 'max_features' }

    select = parameter_form_block.search("select[@id='#{form_id}']")
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
      button = @html.xpath("#{form_xpath}/input[@type='#{type}']")
      is_asserted_by { button.present? }
      is_asserted_by { button.attribute('value').value == value }
    end
  end
end

shared_examples '分析ジョブテーブルが表示されていること' do |rows: 0|
  before do
    @table = @html.xpath(table_xpath)
    @rows = @table.search('tbody/tr')
  end

  it '7列のテーブルが表示されていること' do
    is_asserted_by { @table.search('thead/th').size == 7 }
  end

  %w[実行開始日時 学習データ数 特徴量の数 エントリー数 パラメーター 状態].each_with_index do |text, i|
    it "#{i + 1}列目のヘッダーが#{text}であること" do
      is_asserted_by { @table.search('thead/th')[i].text == text }
    end
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
      is_asserted_by { tds[1].text.strip == analysis.num_data.to_s }
      is_asserted_by { tds[2].text.strip == analysis.num_feature.to_s }
      is_asserted_by { tds[3].text.strip == analysis.num_entry.to_s }
      is_asserted_by { tds[5].text.strip == state_map[analysis.state] }
    end
  end

  it 'パラメーター表示ボタンが表示されていること' do
    @analyses.each_with_index do |analysis, i|
      button = @rows[i].search('td')[4].search('button')
      is_asserted_by { button.present? }
      is_asserted_by { button.text.strip == '確認' }
    end
  end

  it '再実行ボタンが表示されていること' do
    @analyses.each_with_index do |analysis, i|
      rebuild_form = @rows[i].search('td')[6].search('form')
      is_asserted_by { rebuild_form.present? }

      inputs = rebuild_form.search('input')
      analysis_id = analysis.analysis_id
      is_asserted_by { inputs[1].attribute('id').value == "num_data-#{analysis_id}" }
      is_asserted_by { inputs[1].attribute('value').value == analysis.num_data.to_s }
      is_asserted_by { inputs[2].attribute('id').value == "num_entry-#{analysis_id}" }
      is_asserted_by do
        inputs[2].attribute('value')&.value.to_i == analysis.num_entry.to_i
      end
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
        td_children.search('i[@class="fa fa-refresh fa-spin"]').present?
      end
    end
  end

  it '完了の場合は結果画面へのボタンが表示されていること', if: state == '完了' do
    @rows.each do |row|
      td_children = row.search('td')[5].children
      button_xpath = 'a/button[@class="btn btn-xs btn-success"]' \
                     '/span[@class="glyphicon glyphicon-new-window"]'

      is_asserted_by { td_children.search(button_xpath).present? }
    end
  end

  it 'エントリー数が表示されていること', if: num_entry > 0 do
    @rows.each do |row|
      is_asserted_by { row.search('td')[3].text.strip.to_i == num_entry }
    end
  end
end

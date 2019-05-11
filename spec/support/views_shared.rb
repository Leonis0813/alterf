# coding: utf-8

shared_context 'HTML初期化' do
  before(:all) { @html = nil }
end

shared_examples 'ヘッダーが表示されていること' do
  base_xpath =
    '//div[@class="navbar navbar-default navbar-static-top"]/div[@class="container"]'
  ul_xpath = [
    base_xpath,
    'div[@class="navbar-collapse collapse navbar-responsive-collapse"]',
    'ul[@class="nav navbar-nav"]',
  ].join('/')

  it 'アプリ名が表示されていること' do
    title = @html.xpath([base_xpath, 'span[@class="navbar-brand"]'].join('/'))
    is_asserted_by { title.present? }
    is_asserted_by { title.text == 'Horse-Race Estimator' }
  end

  [
    ['/analyses', '分析画面'],
    ['/predictions', '予測画面'],
    ['/evaluations', '評価画面'],
  ].each do |href, text|
    it 'リンクが表示されていること' do
      link = @html.xpath("#{ul_xpath}/li/a[@href='#{href}']")
      is_asserted_by { link.present? }
      is_asserted_by { link.text == text }
    end
  end
end

shared_examples '表示件数情報が表示されていること' do |total: 0, from: 0, to: 0|
  it 'タイトルが表示されていること' do
    title = @html.xpath("#{table_panel_xpath}/h3")
    is_asserted_by { title.present? }
    is_asserted_by { title.text == 'ジョブ実行履歴' }
  end

  it '件数情報が表示されていること' do
    number = @html.xpath("#{table_panel_xpath}/h4")
    is_asserted_by { number.present? }
    is_asserted_by { number.text == "#{total}件中#{from}〜#{to}件を表示" }
  end
end

shared_examples 'ページングボタンが表示されていないこと' do
  it do
    paging = @html.xpath("#{table_panel_xpath}/nav/ul[@class='pagination']")
    is_asserted_by { paging.blank? }
  end
end

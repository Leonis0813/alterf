# coding: utf-8

require 'rails_helper'

describe 'analyses/show', type: :view do
  include_context 'トランザクション作成'
  before(:all) { @analysis = create(:analysis) }

  before(:each) do
    render template: 'analyses/show', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  include_context 'HTML初期化'
  it_behaves_like 'ヘッダーが表示されていること'

  it 'タイトルが表示されていること' do
    title = @html.xpath('//div[@id="main-content"]/h3')
    is_asserted_by { title.present? }
    is_asserted_by { title.text.strip == '分析結果' }
  end

  it '重要度描画領域があること' do
    base_xpath = '//div[@id="main-content"]/div[@class="well"]'

    title = @html.xpath("#{base_xpath}/h4")
    is_asserted_by { title.present? }
    is_asserted_by { title.text.strip == '重要度' }

    svg = @html.xpath("#{base_xpath}/svg[@id='importance']")
    is_asserted_by { svg.present? }
  end

  it '描画メソッドに引数が設定されていること' do
    script_lines = @html.search('script').children.first.text.lines
    is_asserted_by do
      script_lines.any? do |line|
        line.strip == "result.drawImportance('#{@analysis.analysis_id}');"
      end
    end
  end
end

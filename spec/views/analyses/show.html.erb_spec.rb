# coding: utf-8

require 'rails_helper'

describe 'analyses/show', type: :view do
  content_xpath = '//div[@id="main-content"]'

  include_context 'トランザクション作成'
  before(:all) { @analysis = create(:analysis) }

  before do
    render template: 'analyses/show', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  include_context 'HTML初期化'
  it_behaves_like 'ヘッダーが表示されていること'

  it 'タイトルが表示されていること' do
    title = @html.xpath("#{content_xpath}/h3")
    is_asserted_by { title.present? }
    is_asserted_by { title.text.strip == '分析結果' }
  end

  [
    %w[importance 重要度],
    %w[decision_tree 決定木],
  ].each do |tab_id, text|
    it "#{text}を表示するタブが表示されていること" do
      link_xpath = [
        "#{content_xpath}/ul[@class='nav nav-tabs']",
        'li[contains(@class, "nav-item")]',
        "button[contains(@class, 'nav-link')][@data-bs-target='#tab-#{tab_id}']",
      ].join('/')

      link = @html.xpath(link_xpath)
      is_asserted_by { link.present? }
      is_asserted_by { link.text == text }
    end

    it "#{text}描画領域があること" do
      base_xpath = [
        content_xpath,
        'div[@class="tab-content"]',
        "div[@id='tab-#{tab_id}'][contains(@class, 'card')]",
        'div[@class="card-body"]',
      ].join('/')

      title = @html.xpath("#{base_xpath}/h4[@class='card-title']")
      is_asserted_by { title.present? }
      is_asserted_by { title.text.strip == text }

      svg = @html.xpath("#{base_xpath}/svg[@id='#{tab_id}']")
      is_asserted_by { svg.present? }
    end
  end

  it '決定木選択フォームが表示されていること' do
    form_xpath = [
      content_xpath,
      'div[@class="tab-content"]',
      'div[@id="tab-decision_tree"]',
      'div[@class="card-body"]',
      'div[@class="form-inline"]',
    ].join('/')
    select_label = @html.xpath("#{form_xpath}/label[@for='tree_id']")
    is_asserted_by { select_label.present? }
    is_asserted_by { select_label.text == 'Tree ID' }

    select_form_xpath = "#{form_xpath}/select[@id='tree_id'][@class='form-select']"
    select_form = @html.xpath(select_form_xpath)
    is_asserted_by { select_form.present? }

    selected_option = @html.xpath("#{select_form_xpath}/option[@selected]")
    is_asserted_by { selected_option.attribute('value').value == '0' }
  end
end

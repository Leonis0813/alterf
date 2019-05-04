# coding: utf-8
require 'rails_helper'

describe 'evaluations/manage', type: :view do
  per_page = 1
  message_map = {'warning' => '実行中', 'success' => '完了'}
  row_xpath = '//div[@id="main-content"]/div[@class="row center-block"]'

  shared_context '評価ジョブを登録する' do |num|
    before(:all) do
      num.times do
        param = {
          model: 'model',
          state: %w[ processing completed ].sample,
        }
        Evaluation.create!(param)
      end
      @evaluations = Evaluation.order(created_at: :desc).page(1)
    end

    after(:all) { Evaluation.destroy_all }
  end

  shared_examples '入力フォームが表示されていること' do
    form_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-4"]',
      'div[@id="new-evaluation"]',
    ].join('/')

    it 'タイトルが表示されていること'do
      expect(@html).to have_selector("#{form_panel_xpath}/h3", text: 'モデルを評価')
    end

    form_xpath = [
      form_panel_xpath,
      'form[action="/evaluations"][data-remote=true][method="post"][@class="new_evaluation"]',
    ].join('/')
    input_xpath = "#{form_xpath}/div[@class='form-group']"

    %w[ model ].each do |param|
      it "evaluation_#{param}を含む<label>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/label[for='evaluation_#{param}']")
      end

      it "evaluation_#{param}を含む<input>タグがあること" do
        expect(@html).to have_selector("#{input_xpath}/input[id='evaluation_#{param}']")
      end
    end

    %w[ submit reset ].each do |type|
      it "typeが#{type}のボタンがあること" do
        expect(@html).to have_selector("#{form_xpath}/input[type='#{type}']")
      end
    end
  end

  shared_examples 'ジョブ実行履歴が表示されていること' do |expected_size: 0, total: 0, from: 0, to: 0|
    table_panel_xpath = [
      row_xpath,
      'div[@class="col-lg-8"]',
    ].join('/')

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{table_panel_xpath}/h4", text: 'ジョブ実行履歴')
    end

    it '件数情報が表示されていること' do
      info_xpath = "#{table_panel_xpath}/h4"
      expect(@html).to have_selector(info_xpath, text: "#{total}件中#{from}〜#{to}件を表示")
    end

    paging_xpath = "#{table_panel_xpath}/nav/ul[@class='pagination']"

    it '先頭のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='first']/a"
      expect(@html).not_to have_selector(xpath, text: I18n.t('views.list.pagination.first'))
    end

    it '前のページへのボタンが表示されていないこと' do
      xpath = "#{paging_xpath}/li[@class='pagination']/span[@class='prev']/a"
      expect(@html).not_to have_selector(xpath, text: I18n.t('views.list.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item active']"
      expect(@html).to have_selector(xpath, text: 1)
    end

    it '2ページ目が表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/a[href='/evaluations?page=2']"
      expect(@html).to have_selector(xpath, text: 2)
    end

    it '次のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='next']/a[href='/evaluations?page=2']"
      expect(@html).to have_selector(xpath, text: I18n.t('views.pagination.next'))
    end

    it '最後のページへのボタンが表示されていること' do
      xpath = "#{paging_xpath}/li[@class='page-item']/span[@class='last']/a"
      expect(@html).to have_selector(xpath, text: I18n.t('views.pagination.last'))
    end

    %w[ 実行開始日時 モデル 状態 ].each do |header|
      it "ヘッダー(#{header})があること" do
        expect(@html).to have_selector("#{table_panel_xpath}/table[@class='table table-hover']/thead/th", text: header)
      end
    end

    it 'データの数が正しいこと' do
      table_body_xpath = "#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr"
      expect(@html).to have_xpath(table_body_xpath, count: expected_size)
    end

    it '背景色が正しいこと' do
      html_lines = @html.lines.map(&:chomp).map(&:strip)

      while true do
        class_index = html_lines.index {|line| line.start_with?('<tr') }
        state_index = html_lines.index {|line| line.match(/class='td-state'/) }
        break unless class_index

        html_class = html_lines[class_index].match(/class='(.*)'/)[1]
        html_state = html_lines[state_index].match(/>(.*)</)[1]
        is_asserted_by { html_state.include?(message_map[html_class]) }
        html_lines = html_lines[state_index + 1 .. -1]
      end
    end
  end

  before(:all) do
    Kaminari.config.default_per_page = per_page
    @evaluation = Evaluation.new
  end

  before(:each) do
    render template: 'evaluations/manage', layout: 'layouts/application'
    @html ||= response
  end

  describe '<html><body>' do
    include_context '評価ジョブを登録する', 10
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '入力フォームが表示されていること'
    it_behaves_like 'ジョブ実行履歴が表示されていること',
                      expected_size: 1,
                      total: 10,
                      from: 1,
                      to: 1
  end
end
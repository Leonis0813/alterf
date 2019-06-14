# coding: utf-8

require 'rails_helper'

describe 'evaluations/show', type: :view do
  default_attribute = {evaluation_id: '0' * 32, model: 'model', state: 'processing'}

  def table_panel_xpath
    [
      '//div[@id="main-content"]',
      'div[@class="col-lg-12 well"]',
    ].join('/')
  end

  shared_context '評価データを作成する' do |numbers: []|
    before(:all) do
      @evaluation = Evaluation.create!(
        evaluation_id: '0' * 32,
        model: 'model',
        state: 'completed',
        precision: 75.0,
      )
      datum = @evaluation.data.create!(
        race_name: 'テスト',
        race_url: 'http://example.com',
        ground_truth: 1,
      )
      numbers.each {|number| datum.prediction_results.create!(number: number) }
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like 'テーブルが表示されていること'

    it 'タイトルが表示されていること' do
      xpath = [table_panel_xpath, 'h3'].join('/')
      is_asserted_by { @html.xpath(xpath).text.strip == '評価結果詳細' }
    end

    it '精度が表示されていること' do
      xpath = [table_panel_xpath, 'h4'].join('/')
      is_asserted_by { @html.xpath(xpath).text.strip == "精度: #{@evaluation.precision}%" }
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 1|
    before(:each) do
      xpath = [table_panel_xpath, 'table[@class="table table-hover"]'].join('/')
      @table = @html.xpath(xpath)
    end

    it '3列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 3 }
    end

    %w[レース名 予測結果 正解].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples '予測結果の行のデザインが正しいこと' do |tr_class: 'success'|
    before(:each) do
      @rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
    end

    it '行の色が正しいこと' do
      @evaluation.data.size.times do |i|
        is_asserted_by { @rows[i].attribute('class').value == tr_class }
      end
    end

    it 'レース名が正しいこと' do
      @evaluation.data.each_with_index do |datum, i|
        race_name = @rows[i].children.search('td')[0]
        is_asserted_by { race_name.text.strip == datum.race_name }
      end
    end

    it 'レース名がリンクになっていること' do
      @evaluation.data.each_with_index do |datum, i|
        race_url = @rows[i].children.search('td')[0].children.search('a')
        is_asserted_by { race_url.attribute('href').value == datum.race_url }
      end
    end

    it '予測結果が表示されていること' do
      @evaluation.data.each_with_index do |datum, i|
        span_stacks = @rows[i].children.search('td')[1].children.search('span')

        datum.prediction_results.each_with_index do |result, j|
          is_asserted_by { span_stacks[j].attribute('class').value == 'fa-stack' }

          color = result.number == datum.ground_truth ? 'limegreen' : 'gray'
          is_asserted_by do
            span_stacks[j].attribute('style').value == "font-size: 1em;color: #{color}"
          end

          circle, number = span_stacks[j].children.search('i')
          is_asserted_by do
            circle.attribute('class').value == 'fa fa-circle fa-stack-2x'
          end
          is_asserted_by do
            number.attribute('class').value == 'fa fa-stack-1x fa-inverse'
          end
          is_asserted_by { number.text.strip == result.number.to_s }
        end
      end
    end

    it '正解が表示されていること' do
      @evaluation.data.each_with_index do |datum, i|
        span_stack = @rows[i].children.search('td')[2].children.search('span')
        is_asserted_by { span_stack.attribute('class').value == 'fa-stack' }
        is_asserted_by do
          span_stack.attribute('style').value == 'font-size: 1em;color: limegreen'
        end

        circle, number = span_stack.children.search('i')
        is_asserted_by { circle.attribute('class').value == 'fa fa-circle fa-stack-2x' }
        is_asserted_by { number.attribute('class').value == 'fa fa-stack-1x fa-inverse' }
        is_asserted_by { number.text.strip == datum.ground_truth.to_s }
      end
    end
  end

  before(:each) do
    render template: 'evaluations/show', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '予測が当たっている場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する', numbers: [1, 3, 9]
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと'
  end

  context '予測が外れている場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する', numbers: [4, 10, 15]
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと', tr_class: 'danger'
  end

  context '予測結果がない場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと', tr_class: 'danger'
  end
end

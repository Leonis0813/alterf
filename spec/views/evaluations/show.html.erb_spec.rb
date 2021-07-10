# coding: utf-8

require 'rails_helper'

describe 'evaluations/show', type: :view do
  def table_panel_xpath
    [
      '//div[@id="main-content"]',
      'div[@class="col-lg-12 card text-dark bg-light"]',
      'div[@class="card-body"]',
    ].join('/')
  end

  shared_context '評価データを作成する' do |wons: [], result_size: 18|
    before(:all) do
      @evaluation = Evaluation.create!(
        evaluation_id: '0' * 32,
        model: 'model',
        state: 'completed',
        precision: 0.75,
        recall: 0.5,
        f_measure: 0.6,
      )
      race = @evaluation.races.create!(
        race_id: '1' * 8,
        race_name: 'テスト',
        race_url: 'http://example.com',
        ground_truth: 1,
      )
      result_size.times do |i|
        race.test_data.create!(number: i + 1, prediction_result: wons.include?(i + 1))
      end
    end
  end

  shared_examples '画面共通テスト' do
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like 'テーブルが表示されていること'

    it 'タイトルが表示されていること' do
      title = @html.xpath([table_panel_xpath, 'h4'].join('/')).text.strip
      is_asserted_by { title == '評価結果詳細' }
    end

    it 'グラフ描画領域があること' do
      xpath = [table_panel_xpath, 'svg[@id="performance"]'].join('/')
      is_asserted_by { @html.xpath(xpath).present? }
    end
  end

  shared_examples 'テーブルが表示されていること' do |rows: 1|
    before(:each) do
      xpath = [table_panel_xpath, 'table[@class="table table-hover"]'].join('/')
      @table = @html.xpath(xpath)
    end

    it '5列のテーブルが表示されていること' do
      is_asserted_by { @table.xpath('//thead/th').size == 5 }
    end

    %w[No レース名 エントリー数 予測結果 正解].each_with_index do |text, i|
      it "#{i + 1}列目のヘッダーが#{text}であること" do
        is_asserted_by { @table.xpath('//thead/th')[i].text == text }
      end
    end

    it 'ジョブの数が正しいこと' do
      is_asserted_by { @table.xpath('//tbody/tr').size == rows }
    end
  end

  shared_examples '予測結果の行のデザインが正しいこと' do |tr_class: 'table-success'|
    before(:each) do
      @rows =
        @html.xpath("#{table_panel_xpath}/table[@class='table table-hover']/tbody/tr")
    end

    it 'Noが正しいこと' do
      @evaluation.races.size.times do |i|
        is_asserted_by { @rows[i].children.search('td')[0].text.strip == (i + 1).to_s }
      end
    end

    it '行の色が正しいこと' do
      @evaluation.races.size.times do |i|
        is_asserted_by do
          @rows[i].attribute('class').value == "cursor-pointer #{tr_class}"
        end
      end
    end

    it 'レース名が正しいこと' do
      @evaluation.races.each_with_index do |race, i|
        race_name = @rows[i].children.search('td')[1]
        is_asserted_by { race_name.text.strip == race.race_name }
      end
    end

    it 'レース名がリンクになっていること' do
      @evaluation.races.each_with_index do |race, i|
        race_url = @rows[i].children.search('td')[1].children.search('a')
        is_asserted_by { race_url.attribute('href').value == race.race_url }
      end
    end

    it 'エントリー数が表示されていないこと', if: tr_class == 'table-warning' do
      @rows.each do |row|
        num_entry = row.children.search('td')[2]
        is_asserted_by { num_entry.text.strip.blank? }
      end
    end

    it 'エントリー数が正しいこと', unless: tr_class == 'table-warning' do
      @evaluation.races.each_with_index do |race, i|
        num_entry = @rows[i].children.search('td')[2]
        is_asserted_by { num_entry.text.strip == race.test_data.size.to_s }
      end
    end

    it '予測結果が表示されていること', unless: tr_class == 'table-warning' do
      expected_span_class = 'fa-layers fa-fw fa-2x prediction-result'

      @evaluation.races.each_with_index do |race, i|
        span_stacks = @rows[i].children.search('td')[3].children.search('span')

        race.test_data.won.each_with_index do |result, j|
          is_asserted_by do
            span_stacks[j].attribute('class').value == expected_span_class
          end

          color = result.number == race.ground_truth ? 'limegreen' : 'gray'
          is_asserted_by { span_stacks[j].attribute('style').value == "color: #{color}" }

          circle, number = span_stacks[j].children.search('i')
          is_asserted_by do
            circle.attribute('class').value == 'fa fa-circle'
          end
          is_asserted_by do
            number.attribute('class').value == 'fa-layers-text fa-inverse fa-xs'
          end
          is_asserted_by { number.text.strip == result.number.to_s }
        end
      end
    end

    it '正解が表示されていること' do
      expected_span_class = 'fa-layers fa-fw fa-2x prediction-result'

      @evaluation.races.each_with_index do |race, i|
        span_stack = @rows[i].children.search('td')[4].children.search('span')
        is_asserted_by do
          span_stack.attribute('class').value == expected_span_class
        end
        is_asserted_by { span_stack.attribute('style').value == 'color: limegreen' }

        circle, number = span_stack.children.search('i')
        is_asserted_by { circle.attribute('class').value == 'fa fa-circle' }
        is_asserted_by do
          number.attribute('class').value == 'fa-layers-text fa-inverse fa-xs'
        end
        is_asserted_by { number.text.strip == race.ground_truth.to_s }
      end
    end
  end

  before(:each) do
    render template: 'evaluations/show', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  context '予測が当たっている場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する', wons: [1, 3, 9]
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと'
  end

  context '予測が外れている場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する', wons: [4, 10, 15]
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと', tr_class: 'table-danger'
  end

  context '予測結果がない場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する'
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと', tr_class: 'table-danger'
  end

  context 'ジョブが完了していない場合' do
    include_context 'トランザクション作成'
    include_context '評価データを作成する', result_size: 0
    include_context 'HTML初期化'
    it_behaves_like '画面共通テスト'
    it_behaves_like '予測結果の行のデザインが正しいこと', tr_class: 'table-warning'
  end
end

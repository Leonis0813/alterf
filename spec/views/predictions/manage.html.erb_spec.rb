# coding: utf-8
require 'rails_helper'

describe "predictions/manage", :type => :view do
  html = nil

  before(:all) do
    @prediction = Prediction.new
    @predictions = Prediction.all
  end

  before(:each) do
    render
    html ||= response
  end

  describe '<html><body>' do
    form_xpath = '//form[action="/predictions"][data-remote=true][method="post"][@class="new_prediction"]'
    table_xpath = '//table[@class="table table-hover"]'

    describe '<form>' do
      it '<form>タグがあること' do
        expect(html).to have_selector(form_xpath)
      end

      input_span_xpath = "#{form_xpath}/div[@class='form-group']"

      %w[ model test_data ].each do |param|
        it "prediction_#{param}を含む<label>タグがあること" do
          expect(html).to have_selector("#{input_span_xpath}/label[for='prediction_#{param}']")
        end

        it "prediction_#{param}を含む<input>タグがあること" do
          expect(html).to have_selector("#{input_span_xpath}/input[id='prediction_#{param}']")
        end
      end

      %w[ submit reset ].each do |type|
        it "typeが#{type}のボタンがあること" do
          expect(html).to have_selector("#{form_xpath}/input[type='#{type}']")
        end
      end
    end

    describe '<table' do
      it '<table>タグがあること' do
        expect(html).to have_selector(table_xpath)
      end

      %w[ 実行開始日時 モデル テストデータ 状態 ].each do |header|
        it "#{header}を表示する<th>タグがあること" do
          expect(html).to have_selector("#{table_xpath}/thead/th", :text => header)
        end
      end
    end
  end
end

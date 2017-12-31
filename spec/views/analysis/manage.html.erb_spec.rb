# coding: utf-8
require 'rails_helper'

describe "analysis/manage", :type => :view do
  html = nil

  before(:all) do
    @analysis = Analysis.new
  end

  before(:each) do
    render
    html ||= response
  end

  describe '<html><body>' do
    form_xpath = '//form[action="/analysis/learn"][data-remote=true][method="post"][@class="form-inline"]'

    describe '<form>' do
      it '<form>タグがあること' do
        expect(html).to have_selector(form_xpath)
      end

      input_span_xpath = "#{form_xpath}/span[@class='input-custom']"

      %w[ num_data num_tree num_feature ].each do |param|
        it "analysis_#{param}を含む<label>タグがあること" do
          expect(html).to have_selector("#{input_span_xpath}/label[for='analysis_#{param}']")
        end

        it "analysis_#{param}を含む<input>タグがあること" do
          expect(html).to have_selector("#{input_span_xpath}/input[id='analysis_#{param}']")
        end
      end

      submit_span_xpath = "#{form_xpath}/span[@class='pull-right']"

      %w[ submit reset ].each do |type|
        it "typeが#{type}のボタンがあること" do
          expect(html).to have_selector("#{submit_span_xpath}/input[type='#{type}']")
        end
      end
    end
  end
end

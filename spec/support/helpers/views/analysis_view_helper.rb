# -*- coding: utf-8 -*-

require_relative 'common_view_helper'

module AnalysisViewHelper
  include CommonViewHelper

  def form_panel_xpath
    [row_xpath, 'div[@class="col-lg-3"]', 'div[@id="new-analysis"]'].join('/')
  end

  def form_xpath
    [
      form_panel_xpath,
      'form[@action="/analyses"][@data-remote="true"][@method="post"]' \
      '[@class="new_analysis"]',
    ].join('/')
  end

  def parameter_form_block_xpath
    [form_xpath, 'div[@class="collapse"]', 'div[@class="form-group"]'].join('/')
  end

  def link_two_xpath
    super('/analyses')
  end

  def link_next_xpath
    super('/analyses')
  end

  def table_panel_xpath
    [row_xpath, 'div[@class="col-lg-9 well"]'].join('/')
  end

  def table_xpath
    [table_panel_xpath, 'table[@id="table-analysis"]'].join('/')
  end

  def download_link_xpath
    [
      'button[@class="btn btn-default"]',
      'span[@class="glyphicon glyphicon-download-alt"]',
    ].join('/')
  end

  def result_button_xpath
    [
      'a/button[@class="btn btn-xs btn-success"]',
      'span[@class="glyphicon glyphicon-new-window"]',
    ].join('/')
  end
end

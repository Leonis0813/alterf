# -*- coding: utf-8 -*-

require_relative 'common_view_helper'

module AnalysisViewHelper
  include CommonViewHelper

  def form_xpath
    [row_xpath, 'div[@class="col-lg-3"]'].join('/')
  end

  def form_tab_xpath
    [form_xpath, 'ul[@class="nav nav-tabs"]'].join('/')
  end

  def register_form_panel_xpath
    [form_xpath, 'div[@class="tab-content"]', 'div[@id="new-analysis"]'].join('/')
  end

  def register_form_xpath
    [
      register_form_panel_xpath,
      'form[@action="/analyses"][@data-remote="true"][@method="post"]' \
      '[@class="new_analysis"]',
    ].join('/')
  end

  def register_input_xpath
    [register_form_xpath, 'div[@class="form-group"]'].join('/')
  end

  def parameter_form_block_xpath
    [register_form_xpath, 'div[@class="collapse"]', 'div[@class="form-group"]'].join('/')
  end

  def index_form_panel_xpath
    [form_xpath, 'div[@class="tab-content"]', 'div[@id="search-form"]'].join('/')
  end

  def index_form_xpath
    [
      index_form_panel_xpath,
      'form[@action="/analyses"][@method="get"][@id="form-index"]',
    ].join('/')
  end

  def index_input_xpath
    [index_form_xpath, 'div[@class="form-group"]'].join('/')
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

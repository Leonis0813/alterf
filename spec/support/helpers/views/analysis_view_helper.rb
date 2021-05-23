# -*- coding: utf-8 -*-

require_relative 'common_view_helper'

module AnalysisViewHelper
  include CommonViewHelper

  def data_source_map
    {
      'random' => 'ランダム',
      'file' => 'ファイル',
    }
  end

  def form_xpath
    [row_xpath, 'div[@class="col-lg-3"]'].join('/')
  end

  def form_tab_xpath
    [form_xpath, 'ul[@class="nav nav-tabs"]'].join('/')
  end

  def register_form_panel_xpath
    [
      form_xpath,
      'div[@class="tab-content"]',
      'div[@id="new-analysis"][contains(@class, "card")]',
      'div[@class="card-body"]',
    ].join('/')
  end

  def register_form_xpath
    [
      register_form_panel_xpath,
      'form[@action="/analyses"][@data-remote="true"][@method="post"]' \
      '[@class="new_analysis"]',
    ].join('/')
  end

  def register_input_xpath
    [register_form_xpath, 'div[@class="mb-3"]'].join('/')
  end

  def register_parameter_form_xpath
    [register_input_xpath, 'div[@class="mb-2"]'].join('/')
  end

  def index_form_panel_xpath
    [
      form_xpath,
      'div[@class="tab-content"]',
      'div[@id="search-form"][contains(@class, "card")]',
      'div[@class="card-body"]',
    ].join('/')
  end

  def index_form_xpath
    [
      index_form_panel_xpath,
      'form[@action="/analyses"][@method="get"][@id="form-index"]',
    ].join('/')
  end

  def index_input_xpath
    [index_form_xpath, 'div[@class="mb-3"]'].join('/')
  end

  def index_parameter_form_xpath
    [index_form_xpath, 'div[@class="mb-2"]'].join('/')
  end

  def link_two_xpath
    super('/analyses')
  end

  def link_next_xpath
    super('/analyses')
  end

  def table_panel_xpath
    [
      row_xpath,
      'div[@class="col-lg-9 card text-dark bg-light"]',
      'div[@class="card-body"]',
    ].join('/')
  end

  def table_xpath
    [table_panel_xpath, 'table[@id="table-analysis"]'].join('/')
  end

  def download_link_xpath
    [
      'button[@class="btn btn-light btn-sm"]',
      'span[@class="bi bi-download"]',
    ].join('/')
  end

  def result_button_xpath
    [
      'a/button[@class="btn btn-sm btn-success"]',
      'span[@class="bi bi-box-arrow-up-right"]',
    ].join('/')
  end
end

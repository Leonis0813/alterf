# -*- coding: utf-8 -*-

require_relative 'common_view_helper'

module EvaluationViewHelper
  include CommonViewHelper

  def data_source_map
    {
      'remote' => 'Top20',
      'file' => 'ファイル',
      'text' => '直接入力',
      'random' => 'ランダム',
    }
  end

  def container_xpath
    '//div[@id="main-content"][@class="container"]'
  end

  def form_tab_xpath
    [container_xpath, 'ul[@class="nav nav-tabs"]'].join('/')
  end

  def form_panel_xpath
    [
      container_xpath,
      'div[@class="card mb-4"]',
      'div[@id="form-evaluation"][@class="card-body collapse show"]',
      'div[@class="tab-content"]',
    ].join('/')
  end

  def form_xpath
    [
      form_panel_xpath,
      'div[@id="new-evaluation"]',
      'form[@action="/evaluations"][@data-remote="true"][@method="post"]' \
      '[@id="new_evaluation"]',
    ].join('/')
  end

  def input_xpath
    [
      form_xpath,
      'div[@class="row"]',
      'div[@class="col-6 mb-3"]',
    ].join('/')
  end

  def table_panel_xpath
    container_xpath
  end

  def table_title_xpath
    [table_panel_xpath, 'h4[@class="table-title"]'].join('/')
  end

  def link_two_xpath
    super('/evaluations')
  end

  def link_next_xpath
    super('/evaluations')
  end

  def table_xpath
    [table_panel_xpath, 'table[@id="table-evaluation"]'].join('/')
  end

  def download_link_xpath(evaluation)
    [
      "a[@href='/evaluations/#{evaluation.evaluation_id}/download']",
      'button[@class="btn btn-success"]',
      'span[@class="bi bi-download"]',
    ].join('/')
  end
end

# -*- coding: utf-8 -*-

module AnalysisViewHelper
  def state_map
    {
      'waiting' => '実行待ち',
      'processing' => '実行中',
      'completed' => '完了',
      'error' => 'エラー',
    }
  end

  def row_xpath
    '//div[@id="main-content"]/div[@class="row center-block"]'
  end

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

  def input_xpath
    [form_xpath, 'div[@class="form-group"]'].join('/')
  end

  def parameter_form_block_xpath
    [form_xpath, 'div[@class="collapse"]', 'div[@class="form-group"]'].join('/')
  end

  def table_panel_xpath
    [row_xpath, 'div[@class="col-lg-9 well"]'].join('/')
  end

  def table_xpath
    [table_panel_xpath, 'table[@id="table-analysis"]'].join('/')
  end

  def paging_xpath
    [table_panel_xpath, 'nav', 'ul[@class="pagination"]'].join('/')
  end

  def link_first_xpath
    [paging_xpath, 'li[@class="pagination"]', 'span[@class="first"]', 'a'].join('/')
  end

  def link_prev_xpath
    [paging_xpath, 'li[@class="pagination"]', 'span[@class="prev"]', 'a'].join('/')
  end

  def link_one_xpath
    [paging_xpath, 'li[@class="page-item active"]', 'a[@class="page-link"]'].join('/')
  end

  def link_two_xpath(model)
    [
      paging_xpath,
      'li[@class="page-item"]',
      "a[@class='page-link'][@href='/#{model.pluralize}?page=2']",
    ].join('/')
  end

  def link_next_xpath(model)
    [
      paging_xpath,
      'li[@class="page-item"]',
      'span[@class="next"]',
      "a[@class='page-link'][@href='/#{model.pluralize}?page=2']",
    ].join('/')
  end

  def link_last_xpath
    [paging_xpath, 'li[@class="page-item"]', 'span[@class="last"]', 'a'].join('/')
  end

  def list_gap_xpath
    [paging_xpath, 'li[@class="page-item disabled"]', 'a[@href="#"]'].join('/')
  end
end

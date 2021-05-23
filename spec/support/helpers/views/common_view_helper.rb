# -*- coding: utf-8 -*-

module CommonViewHelper
  DEFAULT_PER_PAGE = 1

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

  def input_xpath
    [form_xpath, 'div[@class="mb-3"]'].join('/')
  end

  def table_panel_xpath
    [
      row_xpath,
      'div[@class="col-lg-8 card text-dark bg-light"]',
      'div[@class="card-body"]',
    ].join('/')
  end

  def paging_xpath
    [
      table_panel_xpath,
      'span[@id="paginate"]',
      'nav',
      'ul[@class="pagination"]',
    ].join('/')
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

  def link_two_xpath(path)
    [
      paging_xpath,
      'li[@class="page-item"]',
      "a[@class='page-link'][@href='#{path}?page=2']",
    ].join('/')
  end

  def link_next_xpath(path)
    [
      paging_xpath,
      'li[@class="page-item"]',
      'span[@class="next"]',
      "a[@class='page-link'][@href='#{path}?page=2']",
    ].join('/')
  end

  def link_last_xpath
    [paging_xpath, 'li[@class="page-item"]', 'span[@class="last"]', 'a'].join('/')
  end

  def list_gap_xpath
    [paging_xpath, 'li[@class="page-item disabled"]', 'a[@href="#"]'].join('/')
  end
end

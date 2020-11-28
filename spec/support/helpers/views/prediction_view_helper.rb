require_relative 'common_view_helper'

module PredictionViewHelper
  include CommonViewHelper

  def form_panel_xpath
    [row_xpath, 'div[@class="col-lg-4"]', 'div[@id="new-prediction"]'].join('/')
  end

  def form_xpath
    [
      form_panel_xpath,
      'form[@action="/predictions"][@data-remote="true"][@method="post"]' \
      '[@class="new_prediction"]',
    ].join('/')
  end

  def table_xpath
    [table_panel_xpath, 'table[@class="table table-hover"]'].join('/')
  end

  def link_two_xpath
    super('/predictions')
  end

  def link_next_xpath
    super('/predictions')
  end
end

require_relative 'common_view_helper'

module EvaluationViewHelper
  include CommonViewHelper

  def form_panel_xpath
    [row_xpath, 'div[@class="col-lg-4"]', 'div[@id="new-evaluation"]'].join('/')
  end

  def form_xpath
    [
      form_panel_xpath,
      'form[@action="/evaluations"][@data-remote="true"][@method="post"]' \
      '[@class="new_evaluation"]',
    ].join('/')
  end

  def input_xpath
    [form_xpath, 'div[@class="form-group"]'].join('/')
  end

  def link_two_xpath
    super('/evaluations')
  end

  def link_next_xpath
    super('/evaluations')
  end
end

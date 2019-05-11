module ViewHelper
  def row_xpath
    '//div[@id="main-content"]/div[@class="row center-block"]'
  end

  def form_panel_xpath
    [row_xpath, 'div[@class="col-lg-4"]'].join('/')
  end

  def form_xpath(model)
    [
      form_panel_xpath,
      "div[@id='new-#{model}']",
      "form[@action='/#{model.pluralize}'][@data-remote='true'][@method='post']" \
      "[@class='new_#{model}']",
    ].join('/')
  end

  def input_xpath(model)
    [form_xpath(model), 'div[@class="form-group"]'].join('/')
  end

  def table_panel_xpath
    [row_xpath, 'div[@class="col-lg-8 well"]'].join('/')
  end

  def paging_xpath
    [table_panel_xpath, 'nav', 'ul[@class="pagination"]'].join('/')
  end

  module_function :table_panel_xpath
end

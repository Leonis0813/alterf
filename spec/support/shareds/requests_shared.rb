# -*- coding: utf-8 -*-

shared_examples 'ダイアログが正しく表示されていること' do |title, message|
  it 'タイトルが正しいこと' do
    xpath = 'div//h5[@class="modal-title"]'
    is_asserted_by { @dialog.find_element(:xpath, xpath).text == title }
  end

  it 'メッセージが正しいこと' do
    xpath = 'div//div[@class="modal-body"]'
    is_asserted_by { @dialog.find_element(:xpath, xpath).text == message }
  end
end

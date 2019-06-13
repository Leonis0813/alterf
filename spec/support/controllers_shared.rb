# coding: utf-8

shared_examples 'レスポンスが正常であること' do |status: nil, body: nil|
  it 'ステータスコードが正しいこと' do
    is_asserted_by { @response_status == (status || @status) }
  end

  it 'レスポンスボディが正しいこと' do
    is_asserted_by { @response_body == (body || @body) }
  end
end

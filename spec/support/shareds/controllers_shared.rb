# coding: utf-8

shared_examples 'レスポンスが正常であること' do |status: nil, body: nil|
  it 'ステータスコードが正しいこと' do
    expected = (status || @status)
    is_asserted_by { @response_status == expected }
  end

  it 'レスポンスボディが正しいこと' do
    expected = (body || @body)
    is_asserted_by { @response_body == expected }
  end
end

shared_examples 'DBにレコードが追加されていること' do |klass, query|
  it_is_asserted_by { klass.exists?(query.merge(state: 'processing')) }
end

shared_examples 'DBにレコードが追加されていないこと' do |klass, query|
  it_is_asserted_by { not klass.exists?(query.merge(state: 'processing')) }
end

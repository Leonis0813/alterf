# coding: utf-8

shared_examples 'ステータスコードが正しいこと' do |expected_code|
  it_is_asserted_by { @res.status.to_s == expected_code }
end

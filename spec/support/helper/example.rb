# coding: utf-8

shared_examples 'ステータスコードが正しいこと' do |expected_code|
  it_is_asserted_by { @res.status.to_s == expected_code }
end

shared_examples 'エラーコードが正しいこと' do |error_codes|
  it do
    expected_body = error_codes.map {|code| {'error_code' => code} }
    is_asserted_by { @pbody == expected_body }
  end
end

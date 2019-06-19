# coding: utf-8

shared_context 'オブジェクトを検証する' do |attribute|
  before(:all) do
    @object = described_class.new(attribute)
    @object.validate
  end
end

shared_examples 'エラーが発生していないこと' do
  it_is_asserted_by { @object.errors.empty? }
end

shared_examples 'エラーが発生していること' do |absent_keys: [], invalid_keys: []|
  it_is_asserted_by { @object.errors.present? }

  absent_keys.each do |absent_key|
    it "#{absent_key}がないと判定されていること" do
      is_asserted_by { @object.errors.messages[absent_key].include?('absent') }
    end
  end

  invalid_keys.each do |invalid_key|
    it "#{invalid_key}の値が不正と判定されていること" do
      is_asserted_by { @object.errors.messages[invalid_key].include?('invalid') }
    end
  end
end

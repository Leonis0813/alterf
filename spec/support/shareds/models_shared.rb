# coding: utf-8

shared_context 'ActionCableのモックを作成' do
  before do
    @called = false
    allow_any_instance_of(ActionCable::Server::Base).to receive(:broadcast) do
      @called = true
    end
  end
end

shared_examples 'バリデーションエラーにならないこと' do
  it_is_asserted_by { @object.valid? }
end

shared_examples 'エラーメッセージが正しいこと' do |expected_error|
  it "#{expected_error.keys.join(',')}がエラーになっていること" do
    is_asserted_by { @object.errors.messages.keys.sort == expected_error.keys.sort }
  end

  expected_error.each do |key, message|
    it "#{key}のエラーメッセージが#{message}であること" do
      is_asserted_by { @object.errors.messages[key] == [message] }
    end
  end
end

# coding: utf-8
require 'rails_helper'

describe EvaluationsController, type: :controller do
  model = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/model.txt')))
  default_params = {model: model}

  describe '正常系' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(EvaluationJob).to receive(:perform_later).and_return(true)
        @res = client.post('/evaluations', default_params)
        @pbody = JSON.parse(@res.body) rescue nil
      end
    end

    after(:all) { Evaluation.destroy_all }

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスが空であること' do
      is_asserted_by { @pbody == {} }
    end
  end

  describe '異常系' do
    context 'modelがない場合' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow(EvaluationJob).to receive(:perform_later).and_return(true)
          @res = client.post('/evaluations', {})
          @pbody = JSON.parse(@res.body) rescue nil
        end
      end

      it '400エラーが返ること' do
        is_asserted_by { @res.status == 400 }
      end

      it 'エラーメッセージが正しいこと' do
        is_asserted_by { JSON.parse(@res.body) == [{'error_code' => 'absent_param_model'}] }
      end

      context 'modelが不正な場合' do
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            allow(EvaluationJob).to receive(:perform_later).and_return(true)
            @res = client.post('/evaluations', model: 'invalid')
            @pbody = JSON.parse(@res.body) rescue nil
          end
        end

        it '400エラーが返ること' do
          is_asserted_by { @res.status == 400 }
        end

        it 'エラーメッセージが正しいこと' do
          is_asserted_by { JSON.parse(@res.body) == [{'error_code' => 'invalid_param_model'}] }
        end
      end
    end
  end
end
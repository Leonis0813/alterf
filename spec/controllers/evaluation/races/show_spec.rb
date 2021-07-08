# coding: utf-8

require 'rails_helper'

describe Evaluation::RacesController, type: :controller do
  shared_context '評価レース情報を作成する' do
    before do
      evaluation = create(:evaluation)
      @evaluation_id = evaluation.evaluation_id
      @race_id = create(:evaluation_race, evaluation_id: evaluation.id).race_id
    end
  end

  shared_context 'リクエスト送信' do
    before do
      get(:show, params: {evaluation_id: @evaluation_id, race_id: @race_id})
      @response_status = response.status
    end
  end

  describe '正常系' do
    include_context 'トランザクション作成'
    include_context '評価レース情報を作成する'
    include_context 'リクエスト送信'

    it 'ステータスコードが正しいこと' do
      is_asserted_by { @response_status == 200 }
    end
  end

  describe '異常系' do
    context '評価ジョブが存在しない場合' do
      include_context 'トランザクション作成'
      include_context '評価レース情報を作成する'
      before { @evaluation_id = 'not_exist' }
      include_context 'リクエスト送信'

      it 'ステータスコードが正しいこと' do
        is_asserted_by { @response_status == 404 }
      end
    end

    context '評価レース情報が存在しない場合' do
      include_context 'トランザクション作成'
      include_context '評価レース情報を作成する'
      before { @race_id = 'not_exist' }
      include_context 'リクエスト送信'

      it 'ステータスコードが正しいこと' do
        is_asserted_by { @response_status == 404 }
      end
    end
  end
end

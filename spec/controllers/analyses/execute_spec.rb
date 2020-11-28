# coding: utf-8

require 'rails_helper'

describe AnalysesController, type: :controller do
  describe '#execute' do
    default_params = {
      num_data: '1000',
      num_entry: '9',
      parameter: {
        max_depth: '',
        max_features: 'all',
        max_leaf_nodes: '10',
        min_samples_leaf: '1',
        min_samples_split: '2',
        num_tree: '100',
      },
    }

    shared_context 'リクエスト送信' do |params: default_params|
      before do
        allow(AnalysisJob).to receive(:perform_later).and_return(true)
        response = post(:execute, params: params)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    shared_examples 'DBにレコードが登録されていること' do
      it '分析ジョブが登録されていること' do
        is_asserted_by { @analysis.present? }
      end

      it '分析結果が登録されていること' do
        is_asserted_by { @analysis.result.present? }
      end

      it 'パラメーターが登録されていること' do
        is_asserted_by { @analysis.parameter.present? }
      end
    end

    describe '正常系' do
      ['9', ''].each do |num_entry|
        context "num_entryに'#{num_entry}'を指定した場合" do
          params = default_params.merge(num_entry: num_entry)
          include_context 'トランザクション作成'
          include_context 'リクエスト送信', params: params
          before { @analysis = Analysis.find_by(state: 'waiting') }

          it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
          it_behaves_like 'DBにレコードが登録されていること'
        end
      end

      valid_parameter = {
        max_depth: ['1', '10', ''],
        max_features: %w[all sqrt log2],
        max_leaf_nodes: ['1', '10', ''],
        min_samples_leaf: ['1', '10', ''],
        min_samples_split: ['1', '10', ''],
        num_tree: ['1', '10', ''],
      }

      CommonHelper.generate_test_case(valid_parameter).each do |parameter|
        context "parameterに#{parameter}を指定した場合" do
          params = default_params.merge(parameter: parameter)
          include_context 'トランザクション作成'
          include_context 'リクエスト送信', params: params
          before { @analysis = Analysis.find_by(state: 'waiting') }

          it_behaves_like 'レスポンスが正常であること', status: 200, body: {}
          it_behaves_like 'DBにレコードが登録されていること'
        end
      end
    end

    describe '異常系' do
      required_keys = %i[num_data parameter]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}がない場合" do
          selected_keys = required_keys - absent_keys
          errors = absent_keys.map do |key|
            {
              'error_code' => 'absent_parameter',
              'parameter' => key.to_s,
              'resource' => 'analysis',
            }
          end
          errors.sort_by! {|error| [error['error_code'], error['parameter']] }

          include_context 'リクエスト送信', params: default_params.slice(*selected_keys)
          it_behaves_like 'レスポンスが正常であること',
                          status: 400, body: {'errors' => errors}
          it_behaves_like 'DBにレコードが追加されていないこと',
                          Analysis, default_params.slice(:num_data)
        end
      end

      invalid_attribute = {
        num_data: ['invalid', [1], {data: 1}, nil],
        num_entry: ['invalid', [1], {entry: 1}],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
        context "#{invalid_param.keys.join(',')}が不正な場合" do
          errors = invalid_param.keys.map do |key|
            {
              'error_code' => 'invalid_parameter',
              'parameter' => key.to_s,
              'resource' => 'analysis',
            }
          end
          errors.sort_by! {|error| [error['error_code'], error['parameter']] }

          include_context 'リクエスト送信', params: default_params.merge(invalid_param)
          it_behaves_like 'レスポンスが正常であること',
                          status: 400, body: {'errors' => errors}
          it_behaves_like 'DBにレコードが追加されていないこと',
                          Analysis, default_params.slice(:num_data)
        end
      end

      invalid_attribute = {
        max_depth: ['0', '1.0', ['1'], {depth: '1'}],
        max_features: ['invalid', ['all'], {type: 'all'}, nil],
        max_leaf_nodes: ['0', '1.0', ['1'], {nodes: '1'}],
        min_samples_leaf: ['0', '1.0', ['1'], {leaf: '1'}],
        min_samples_split: ['0', '1.0', ['1'], {split: '1'}],
        num_tree: ['0', '1.0', ['1'], {tree: '1'}],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
        context "parameterの#{invalid_param.keys.join(',')}が不正な場合" do
          errors = invalid_param.keys.map do |key|
            {
              'error_code' => 'invalid_parameter',
              'parameter' => key.to_s,
              'resource' => 'analysis',
            }
          end
          errors.sort_by! {|error| [error['error_code'], error['parameter']] }
          params = default_params.merge(parameter: invalid_param)

          include_context 'リクエスト送信', params: params
          it_behaves_like 'レスポンスが正常であること',
                          status: 400, body: {'errors' => errors}
          it_behaves_like 'DBにレコードが追加されていないこと',
                          Analysis, default_params.slice(:num_data)
        end
      end

      context '複合エラーの場合' do
        errors = [
          {
            'error_code' => 'absent_parameter',
            'parameter' => 'num_data',
            'resource' => 'analysis',
          },
          {
            'error_code' => 'invalid_parameter',
            'parameter' => 'num_entry',
            'resource' => 'analysis',
          },
          {
            'error_code' => 'invalid_parameter',
            'parameter' => 'num_tree',
            'resource' => 'analysis',
          },
        ]
        params = {num_entry: 'invalid', parameter: {num_tree: 'invalid'}}
        include_context 'リクエスト送信', params: params
        it_behaves_like 'レスポンスが正常であること',
                        status: 400, body: {'errors' => errors}
        it_behaves_like 'DBにレコードが追加されていないこと', Analysis, {}
      end
    end
  end
end

# coding: utf-8
require 'rails_helper'

describe Api::AnalysesController, :type => :controller do
  result_dir = File.join(Rails.root, 'results')

  describe '正常系' do
    before(:all) do
      FileUtils.mkdir_p(result_dir)
      FileUtils.touch(File.join(result_dir, 'analysis_1.yml'))
      @res = client.get('/api/analyses/1/training_data')
    end

    after(:all) { FileUtils.rm_r(result_dir) }

    it_behaves_like 'ステータスコードが正しいこと', '200'
  end

  describe '異常系' do
    before(:all) { @res = client.get('/api/analyses/not_exist/training_data') }

    it_behaves_like 'ステータスコードが正しいこと', '404'
  end
end

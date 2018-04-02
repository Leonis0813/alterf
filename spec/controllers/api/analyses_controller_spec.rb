# coding: utf-8
require 'rails_helper'

describe Api::AnalysesController, :type => :controller do
  file_path = File.join(Rails.root, 'results/analysis_1.yml')

  describe '正常系' do
    before(:all) do
      FileUtils.touch(file_path)
      @res = client.get('/api/analyses/1/training_data')
    end

    after(:all) { FileUtils.rm(file_path) }

    it_behaves_like 'ステータスコードが正しいこと', '200'
  end

  describe '異常系' do
    before(:all) { @res = client.get('/api/analyses/not_exist/training_data') }

    it_behaves_like 'ステータスコードが正しいこと', '404'
  end
end

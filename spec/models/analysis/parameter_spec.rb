# coding: utf-8

require 'rails_helper'

describe Analysis::Parameter, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        min_samples_leaf: ['2', ''],
        min_samples_split: ['3', ''],
        num_tree: ['1000', ''],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) do
            @object = build(:analysis_parameter, attribute.merge(analysis_id: 1))
          end

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end
  end
end

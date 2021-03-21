# coding: utf-8

require 'rails_helper'

describe Analysis::IndexForm, type: :model do
  describe '.initialize' do
    [
      [1, {key: :value}],
      [nil, {key: :value}],
      [1, nil, {}],
      [nil, nil, {}],
    ].each do |num_data, parameter, expected_parameter|
      expected_parameter ||= parameter

      context "num_data: #{num_data}, parameter: #{parameter}を指定した場合" do
        before(:all) do
          @index_form = Analysis::IndexForm.new(
            num_data: num_data,
            parameter: parameter,
          )
        end

        it "num_dataが#{num_data || 'nil'}であること" do
          is_asserted_by { @index_form.num_data == num_data }
        end

        it "parameterが#{expected_parameter}であること" do
          is_asserted_by { @index_form.parameter == expected_parameter }
        end
      end
    end
  end

  describe '#to_query' do

  end
end

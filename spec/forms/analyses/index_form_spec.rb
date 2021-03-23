# coding: utf-8

require 'rails_helper'

describe Analyses::IndexForm, type: :model do
  describe '.initialize' do
    [
      [1, {key: :value}],
      [nil, {key: :value}],
      [1, nil, {}],
      [nil, nil, {}],
    ].each do |num_data, parameter, expected_parameter|
      expected_parameter ||= parameter.with_indifferent_access

      context "num_data: #{num_data}, parameter: #{parameter}を指定した場合" do
        before(:all) do
          @index_form = Analyses::IndexForm.new(
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
    [
      [1, {max_depth: 1}, {'analysis_parameters.max_depth' => 1, 'num_data' => 1}],
      [nil, {max_depth: 1}, {'analysis_parameters.max_depth' => 1}],
      [nil, {max_features: 'sqrt'}, {'analysis_parameters.max_features' => 'sqrt'}],
      [nil, {max_leaf_nodes: 1}, {'analysis_parameters.max_leaf_nodes' => 1}],
      [nil, {min_samples_leaf: 1}, {'analysis_parameters.min_samples_leaf' => 1}],
      [nil, {min_samples_split: 1}, {'analysis_parameters.min_samples_split' => 1}],
      [nil, {num_tree: 1}, {'analysis_parameters.num_tree' => 1}],
      [1, nil, {'num_data' => 1}],
      [nil, nil, {}],
    ].each do |num_data, parameter, expected_query|
      context "num_data: #{num_data}, parameter: #{parameter}を指定した場合" do
        before(:all) do
          @index_form = Analyses::IndexForm.new(
            num_data: num_data,
            parameter: parameter,
          )
        end

        it "#{expected_query}が返ること" do
          is_asserted_by { @index_form.to_query == expected_query }
        end
      end
    end
  end
end

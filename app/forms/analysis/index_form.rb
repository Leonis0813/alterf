class Analysis
  class IndexForm
    PARAMETER_ATTRIBUTE_NAMES = %w[
      max_depth
      max_features
      max_leaf_nodes
      min_samples_leaf
      min_samples_split
      num_tree
    ].freeze

    attr_accessor :num_data, :parameter

    def initialize(attribute = {})
      self.num_data = attribute[:num_data]
      self.parameter = attribute[:parameter] || {}
    end

    def to_query
      PARAMETER_ATTRIBUTE_NAMES.map do |name|
        ["analysis_parameters.#{name}", parameter[name]]
      end.to_h.merge('num_data' => num_data).compact
    end
  end
end

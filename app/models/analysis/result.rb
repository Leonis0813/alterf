class Analysis
  class Result < ApplicationRecord
    belongs_to :analysis
    has_many :importances,
             foreign_key: 'analysis_result_id',
             dependent: :destroy,
             inverse_of: :result
    has_many :decision_trees,
             foreign_key: 'analysis_result_id',
             dependent: :destroy,
             inverse_of: :result

    def import!
      output_dir = Rails.root.join('tmp', 'files', 'analyses', analysis.id.to_s)
      raise StandardError unless File.exist?(output_dir)

      metadata = YAML.load_file(File.join(output_dir, 'metadata.yml'))
      metadata['importance'].each do |feature_name, value|
        importances.create!(feature_name: feature_name, value: value)
      end

      metadata['num_tree'].times do |i|
        decision_tree = decision_trees.create!(tree_id: i)
        decision_tree.import!
      end
    end
  end
end

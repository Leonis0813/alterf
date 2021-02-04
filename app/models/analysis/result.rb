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
      attributes = metadata['importance'].map do |feature_name, value|
        {feature_name: feature_name, value: value}.merge(timestamp)
      end
      importances.insert_all!(attributes)

      attributes = metadata['num_tree'].times.map {|i| {tree_id: i}.merge(timestamp) }
      decision_trees.insert_all!(attributes)
      decision_trees.reload.each {|decision_tree| decision_tree.import! }
    end

    private

    def timestamp
      {created_at: Time.zone.now, updated_at: Time.zone.now}
    end
  end
end

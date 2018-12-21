class Analysis < ActiveRecord::Base
  validates :num_data, :numericality => {:only_integer => true, :greater_than => 0}
  validates :num_tree, :numericality => {:only_integer => true, :greater_than => 0}
  validates :state, :inclusion => {:in => %w[ processing completed ]}
end

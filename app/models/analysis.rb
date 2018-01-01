class Analysis < ActiveRecord::Base
  attr_accessor :num_data, :num_tree, :num_feature, :state

  validates :num_data, :numericality => {:only_integer => true, :greater_than => 0}
  validates :num_tree, :numericality => {:only_integer => true, :greater_than => 0}
  validates :num_feature, :numericality => {:only_integer => true, :greater_than => 0}
end

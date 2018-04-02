class Api::AnalysesController < ApplicationController
  def download_training_data
    file_path = File.join(Rails.root, "results/analysis_#{params[:analysis_id]}.yml")
    if File.exists?(file_path)
      send_data(File.read(file_path), filename: File.basename(file_path))
    else
      raise NotFound.new
    end
  end
end

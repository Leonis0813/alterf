require_relative '../clients/netkeiba_client'

class FeatureUtil
  def self.create_feature(race_id)
    features = Denebola::Feature.where(race_id: race_id)

    race_feature = features.first.slice(*Settings.prediction.feature.races)
    entry_features = features.map do |feature|
      feature.slice(*Settings.prediction.feature.horses)
    end

    race_feature.tap do |feature|
      feature['entries'] = []

      entry_features.each do |entry_feature|
        feature['entries'] << Settings.prediction.feature.horses.map do |name|
          entry_feature[name]
        end
      end
    end
  end
end

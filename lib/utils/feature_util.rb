require_relative '../clients/netkeiba_client'

class FeatureUtil
  def self.create_feature(race_id)
    features = Denebola::Feature.where(race_id: race_id)

    race_feature = features.first.slice(*Settings.prediction.feature.races)

    entry_attributes = Settings.prediction.feature.horses +
                       Settings.prediction.feature.jockeys

    entry_features = features.map {|feature| feature.slice(*entry_attributes) }

    race_feature.tap do |feature|
      feature['entries'] = []

      entry_features.each do |entry_feature|
        feature['entries'] << entry_attributes.map {|name| entry_feature[name] }
      end
    end
  end
end

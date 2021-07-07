class Denebola::Race < Denebola::Base
  has_many :entries, dependent: :nullify
end

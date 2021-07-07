module Denebola
  class Race < Denebola::Base
    has_many :entries, dependent: :nullify
  end
end

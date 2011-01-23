class Player
  include Mongoid::Document

  field :name

  embedded_in :tournament, inverse_of: :players

  validates_presence_of :name
end

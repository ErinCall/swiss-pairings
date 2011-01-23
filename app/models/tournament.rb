class Tournament
  include Mongoid::Document

  field :name
  field :win_value, type: Float, default: 3.0
  field :draw_value, type: Float, default: 1.0

  embeds_many :players

  validates_presence_of :name
end

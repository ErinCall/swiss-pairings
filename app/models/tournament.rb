class Tournament
  include Mongoid::Document

  field :name
  field :win_value, type: Float, default: 3.0
  field :draw_value, type: Float, default: 1.0
  field :current_round, type: Integer, default: 0
  field :total_rounds, type: Integer

  embeds_many :players
  embeds_many :matches

  validates_presence_of :name

  def calculate_total_rounds
    self.total_rounds = Math.log2(players.count).ceil
    save
  end

  def generate_matches
    inc(:current_round, 1)

    players.sort_by { rand }.each_slice(2) do |slice|
      matches.create(round: current_round, player_1_id: slice[0].id, player_2_id: slice[1] && slice[1].id)
    end
  end

  def current_matches
    matches.where(round: current_round)
  end
end

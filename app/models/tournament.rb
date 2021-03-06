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

  delegate :generate_matches, to: :swiss_pairer

  def started?
    return current_round > 0
  end

  def calculate_total_rounds
    self.total_rounds = Math.log2(players.count).ceil
    save
  end

  def current_matches
    matches.where(round: current_round)
  end

  def unfinished_matches
    current_matches.where(winner: nil, :player_2_id.ne => nil)
  end

  def finished_rounds
    if unfinished_matches.length > 0
      current_round - 1
    else
      current_round
    end
  end

  def finished?
    finished_rounds == total_rounds
  end

  def underway?
    started? && ! finished?
  end

  def matches_for_player(player)
    matches.select { |m| m.player_1_id == player.id || m.player_2_id == player.id }
  end

  def create_match(player_1, player_2)
    matches.create(round: current_round, player_1_id: player_1.id, player_2_id: player_2 && player_2.id)
  end

  def next_round
    inc(:current_round, 1)
  end

  def results
    self.players.sort_by do |p|
      [
        p.match_score,
        p.opponents_match_win_percentage,
        p.game_win_percentage,
        p.opponents_game_win_percentage
      ]
    end.reverse
  end

  private
    def swiss_pairer
      SwissPairer.new(self)
    end
end

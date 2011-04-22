class Player
  include Mongoid::Document

  field :name

  embedded_in :tournament, inverse_of: :players

  validates_presence_of :name

  def match_score
    tournament.matches_for_player(self).reduce(0) do |score, match|
      if match.winner?(self)
        score + tournament.win_value
      elsif match.draw?
        score + tournament.draw_value
      else
        score
      end
    end
  end

  def played?(other_player)
    return false if other_player == self
    !! tournament.matches_for_player(self).find do |m|
      m.player_1_id == other_player.id || m.player_2_id == other_player.id
    end
  end
end

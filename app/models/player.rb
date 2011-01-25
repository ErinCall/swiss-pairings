class Player
  include Mongoid::Document

  field :name

  embedded_in :tournament, inverse_of: :players

  validates_presence_of :name

  def match_score
    score = 0

    tournament.matches_for_player(self).each do |match|
      if match.winner?(self)
        score += tournament.win_value
      elsif match.draw?
        score += tournament.draw_value
      end
    end

    score
  end
end

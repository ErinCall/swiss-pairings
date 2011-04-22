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

  def match_win_percentage
    matches = tournament.matches_for_player(self)
    return 0 if matches.length == 0

    actual_percentage = self.match_score/(3 * matches.length)
    return actual_percentage unless actual_percentage < 0.33
    return 0.33
  end

  def opponents_match_win_percentage
    opponents = self.opponents
    return 0 if opponents.length == 0

    total_percentage = opponents.reduce(0) do |sum, opponent|
      sum + opponent.match_win_percentage
    end

    return total_percentage / opponents.length
  end

  def game_win_percentage
    matches = tournament.matches_for_player(self)
    return 0 if matches.length == 0

    games_played = 0
    game_score = 0.0

    matches.each do |match|
      games_played += match.games_played
      game_score += match.game_score(self)
    end

    game_score / (3 * games_played)
  end

  def opponents_game_win_percentage
    opponents = self.opponents
    return 0 if opponents.length == 0

    total_percentage = opponents.reduce(0) do |sum, opponent|
      percentage = opponent.game_win_percentage
      percentage = 0.33 unless percentage > 0.33
      sum + percentage
    end

    return total_percentage / opponents.length
  end

  def played?(other_player)
    return false if other_player == self
    !! tournament.matches_for_player(self).find do |m|
      m.player_1_id == other_player.id || m.player_2_id == other_player.id
    end
  end

  def opponents
    tournament.players.select { | other | self.played?(other) }
  end

  def <=>(opponent)
    return self.match_score <=> opponent.match_score unless self.match_score == opponent.match_score
    return self.opponents_match_win_percentage <=> opponent.opponents_match_win_percentage unless self.opponents_match_win_percentage == opponent.opponents_match_win_percentage
    return self.game_win_percentage <=> opponent.game_win_percentage unless self.game_win_percentage == opponent.game_win_percentage
    return self.opponents_game_win_percentage <=> opponent.opponents_game_win_percentage unless self.opponents_game_win_percentage == opponent.opponents_game_win_percentage
    return 0
  end
end

class Player
  include Mongoid::Document
  extend ActiveSupport::Memoizable

  field :name

  embedded_in :tournament, inverse_of: :players

  validates_presence_of :name

  MINIMUM_WIN_PERCENTAGE = 0.33

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

    actual_percentage = self.match_score/(tournament.win_value * matches.length)
    [actual_percentage, MINIMUM_WIN_PERCENTAGE].max
  end
  memoize :match_win_percentage

  def opponents_match_win_percentage
    opponents = self.opponents
    return 0 if opponents.length == 0

    total_percentage = opponents.reduce(0) do |sum, opponent|
      sum + opponent.match_win_percentage
    end

    return total_percentage / opponents.length
  end
  memoize :opponents_match_win_percentage

  def game_win_percentage
    matches = tournament.matches_for_player(self)
    return 0 if matches.length == 0

    games_played = 0
    game_score = 0.0

    matches.each do |match|
      games_played += match.games_played
      game_score += match.game_score(self)
    end

    game_score / (tournament.win_value * games_played)
  end
  memoize :game_win_percentage

  def opponents_game_win_percentage
    opponents = self.opponents
    return 0 if opponents.length == 0

    total_percentage = opponents.reduce(0) do |sum, opponent|
      sum + [opponent.game_win_percentage, MINIMUM_WIN_PERCENTAGE].max
    end

    return total_percentage / opponents.length
  end
  memoize :opponents_game_win_percentage

  def played?(other_player)
    return false if other_player == self
    !! tournament.matches_for_player(self).find do |m|
      m.player_1_id == other_player.id || m.player_2_id == other_player.id
    end
  end

  def opponents
    tournament.players.select { | other | self.played?(other) }
  end
end

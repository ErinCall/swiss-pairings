module TournamentsHelper
  def result_class(match, player)
    if match.winner
      if match.winner == player
        'winner'
      elsif match.winner == -1
        'draw'
      else
        'loser'
      end
    else
      nil
    end
  end

  def tournament_status(tournament)
    if tournament.players.count > 0
      pluralize(tournament.players.count, 'player')
    else
      ''
    end
  end
end

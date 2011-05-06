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
    status = pluralize(tournament.players.count, 'player')

    if tournament.finished_rounds > 0
      status << "; #{tournament.finished_rounds} of #{tournament.total_rounds} rounds complete"
    end

    return status
  end
end

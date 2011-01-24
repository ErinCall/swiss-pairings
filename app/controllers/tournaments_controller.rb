class TournamentsController < InheritedResources::Base
  def show
    @player = resource.players.build

    show!
  end

  def start
    if resource.players.count > 1
      @tournament.calculate_total_rounds if @tournament.current_round == 0
      @tournament.generate_matches
    else
      flash[:error] = "Can't start a tournament with less than 2 players"
    end

    redirect_to tournament_path(@tournament)
  end
end

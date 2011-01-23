class TournamentsController < InheritedResources::Base
  def show
    @player = resource.players.build

    show!
  end

  def start
    if resource.players.count > 1
      @tournament.total_rounds = Math.log2(@tournament.players.count).ceil
      @tournament.save

      @tournament.generate_matches
    else
      flash[:error] = "Can't start a tournament with less than 2 players"
    end

    redirect_to tournament_path(@tournament)
  end
end

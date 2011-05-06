class TournamentsController < InheritedResources::Base
  def show
    @player = resource.players.build

    show!
  end

  def start_round
    if resource.players.count > 1
      @tournament.calculate_total_rounds unless @tournament.started?
      @tournament.next_round
      @tournament.generate_matches
    else
      flash[:error] = "Can't start a tournament with less than 2 players"
    end

    redirect_to tournament_path(@tournament)
  end

  protected
    def collection
      @tournaments ||= Tournament.desc(:name)
    end
end

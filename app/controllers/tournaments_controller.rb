class TournamentsController < InheritedResources::Base
  def show
    @player = resource.players.build

    show!
  end
end

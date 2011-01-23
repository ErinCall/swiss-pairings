class PlayersController < InheritedResources::Base
  belongs_to :tournament
  actions :create

  def create
    create! do |success, failure|
      success.html do
        redirect_to tournament_path(@tournament)
      end
      failure.html do
        render 'tournaments/show'
      end
    end
  end
end

class MatchesController < InheritedResources::Base
  belongs_to :tournament
  actions :update

  def update
    update! do |success, failure|
      success.html do
        redirect_to tournament_path(@tournament)
      end
    end
  end
end

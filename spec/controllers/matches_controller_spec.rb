require 'spec_helper'

describe MatchesController do
  describe '#update' do
    let(:match) { mock_model(Match) }
    let(:tournament) { mock_model(Tournament, id: 'foo') }

    before(:each) do
      Tournament.stub(:find).with('foo').and_return(tournament)
      tournament.stub_chain(:matches, :find).and_return(match)
    end

    context 'on success' do
      it 'should redirect to the tournament page' do
        match.stub(:update_attributes).and_return(true)

        put :update, tournament_id: 'foo', id: 'bar', match: {}

        response.should redirect_to('/tournaments/foo')
      end
    end
  end
end

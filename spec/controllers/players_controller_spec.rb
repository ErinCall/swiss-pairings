require 'spec_helper'

describe PlayersController do
  describe '#create' do
    let(:player) { mock_model(Player) }
    let(:tournament) { mock_model(Tournament, id: 'foo') }

    before(:each) do
      Tournament.stub(:find).with('foo').and_return(tournament)
      tournament.stub_chain(:players, build: player)
    end

    context 'on success' do
      it 'should redirect to the tournament page' do
        player.stub(:save).and_return(true)

        post :create, tournament_id: 'foo', player: { name: 'Drew' }

        response.should redirect_to('/tournaments/foo')
      end
    end

    context 'on error' do
      it 'should redirect to the tournament page' do
        player.stub(:save).and_return(false)
        player.stub(:errors).and_return(name: ["can't be blank"])

        post :create, tournament_id: 'foo', player: { name: '' }

        response.should render_template('tournaments/show')
      end
    end
  end
end

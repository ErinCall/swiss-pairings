require 'spec_helper'

describe TournamentsController do
  describe '#start_round' do
    context 'when starting a tournament' do
      let(:tournament) { mock_model(Tournament, id: 'foo', current_round: 0) }
      before(:each) { Tournament.stub(:find).with('foo').and_return(tournament) }

      context 'and there are too few players' do
        before(:each) { tournament.stub_chain(:players, :count).and_return(0) }

        it 'should display an error if there are not enough players' do
          post :start_round, id: 'foo'
          flash[:error].should == "Can't start a tournament with less than 2 players"
        end

        it 'should redirect to the tournament page' do
          post :start_round, id: 'foo'
          response.should redirect_to('/tournaments/foo')
        end
      end

      context 'and there are enough players' do
        before(:each) do
          tournament.stub_chain(:players, :count).and_return(5)
          tournament.stub(:calculate_total_rounds)
          tournament.stub(:generate_matches)
        end

        it 'should calculate the total number of rounds' do
          tournament.should_receive(:calculate_total_rounds)

          post :start_round, id: 'foo'
        end

        it 'should generate the matches for the round' do
          tournament.should_receive(:generate_matches)

          post :start_round, id: 'foo'
        end
      end
    end
  end
end

require 'spec_helper'

describe TournamentsController do
  shared_examples_for 'start_round' do
    it 'should increment the current round' do
      tournament.should_receive(:next_round)

      post :start_round, id: 'foo'
    end

    it 'should generate the matches for the round' do
      tournament.should_receive(:generate_matches)

      post :start_round, id: 'foo'
    end
  end

  describe '#start_round' do
    let(:tournament) { mock_model(Tournament, id: 'foo') }

    context 'when starting a tournament' do
      before(:each) do
        Tournament.stub(:find).with('foo').and_return(tournament)
        tournament.stub(:started?).and_return(false)
      end

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
         it 'should not increment the round' do
           tournament.should_not_receive(:next_round)
         end
      end

      context 'and there are enough players' do
        before(:each) do
          tournament.stub_chain(:players, :count).and_return(5)
          tournament.stub(:calculate_total_rounds)
          tournament.stub(:generate_matches)
          tournament.stub(:next_round)
        end

        it_should_behave_like 'start_round'

        it 'should calculate the total number of rounds' do
          tournament.should_receive(:calculate_total_rounds)

          post :start_round, id: 'foo'
        end
      end
    end

    context 'after the tournament has been started' do
      before(:each) do
        Tournament.stub(:find).with('foo').and_return(tournament)
        tournament.stub(:started?).and_return(true)
        tournament.stub_chain(:players, :count).and_return(5)
        tournament.stub(:generate_matches)
        tournament.stub(:next_round)
      end

      it_should_behave_like 'start_round'

      it 'should not calculate the total number of rounds' do
        tournament.should_not_receive(:calculate_total_rounds)

        post :start_round, id: 'foo'
      end
    end
  end
end

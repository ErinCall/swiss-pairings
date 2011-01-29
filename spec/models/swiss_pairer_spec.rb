require 'spec_helper'

describe SwissPairer do
  describe '#generate_matches' do
    subject { SwissPairer.new(tournament) }
    let(:tournament) { mock_model(Tournament, current_round: 1) }

    it 'should match players by match score' do
      winners = 2.times.map { mock_model(Player, match_score: 3) }
      losers = 2.times.map { mock_model(Player, match_score: 0) }

      tournament.should_receive(:players).and_return(winners + losers)
      tournament.should_receive(:create_match).with(*winners)
      tournament.should_receive(:create_match).with(*losers)

      subject.stub(:rand).and_return(1,2,3,4)

      subject.generate_matches
    end

    it 'should give a bye if there is an uneven number of players' do
      players = 3.times.map { mock_model(Player, match_score: 0) }

      tournament.should_receive(:players).and_return(players)
      tournament.should_receive(:create_match).with(players[0], players[1])
      tournament.should_receive(:create_match).with(players[2], nil)

      subject.stub(:rand).and_return(1,2,3)

      subject.generate_matches
    end

    it 'should move players up from a lower group if there is an odd number in a group' do
      winner = mock_model(Player, match_score: 3)
      drawers = 2.times.map { mock_model(Player, match_score: 1) }
      loser = mock_model(Player, match_score: 0)

      tournament.should_receive(:players).and_return([winner, *drawers, loser])
      tournament.should_receive(:create_match).with(winner, drawers[0])
      tournament.should_receive(:create_match).with(drawers[1], loser)

      subject.stub(:rand).and_return(0,1,2,0,1,2)

      subject.generate_matches
    end
  end
end

require 'spec_helper'

describe SwissPairer do
  describe '#generate_matches' do
    subject { SwissPairer.new(tournament) }
    let(:tournament) { mock_model(Tournament) }

    before(:each) do
      i = 0
      subject.stub(:rand) { |max| max.nil? ? i += 1 : 0 }
    end

    it 'should match players by match score' do
      winners = 2.times.map { mock_model(Player, match_score: 3, played?: false) }
      losers = 2.times.map { mock_model(Player, match_score: 0, played?: false) }

      tournament.should_receive(:players).and_return(winners + losers)
      tournament.should_receive(:create_match).with(*winners)
      tournament.should_receive(:create_match).with(*losers)

      subject.generate_matches
    end

    it 'should give a bye if there is an uneven number of players' do
      players = 3.times.map { mock_model(Player, match_score: 0, played?: false) }

      tournament.should_receive(:players).and_return(players)
      tournament.should_receive(:create_match).with(players[0], players[1])
      tournament.should_receive(:create_match).with(players[2], nil)

      subject.generate_matches
    end

    it 'should move players up from a lower group if there is an odd number in a group' do
      winner = mock_model(Player, match_score: 3, played?: false)
      drawers = 2.times.map { mock_model(Player, match_score: 1, played?: false) }
      loser = mock_model(Player, match_score: 0, played?: false)

      tournament.should_receive(:players).and_return([winner, *drawers, loser])
      tournament.should_receive(:create_match).with(winner, drawers[0])
      tournament.should_receive(:create_match).with(drawers[1], loser)

      subject.generate_matches
    end

    it 'should swap within a score group if there is an illegal match' do
      drawers = 4.times.map { mock_model(Player, match_score: 1, played?: false) }
      drawers[0].stub(:played?).with(drawers[1]).and_return(true)
      drawers[2].stub(:played?).with(drawers[3]).and_return(true)

      tournament.should_receive(:players).and_return(drawers)
      tournament.should_receive(:create_match).with(drawers[0], drawers[2])
      tournament.should_receive(:create_match).with(drawers[1], drawers[3])

      subject.generate_matches
    end

    it 'should swap with the score group below if there is still an illegal match' do
      winners = 2.times.map { mock_model(Player, match_score: 3, played?: false) }
      drawers = 2.times.map { mock_model(Player, match_score: 1, played?: false) }
      losers = 2.times.map { mock_model(Player, match_score: 0, played?: false) }
      drawers[0].stub(:played?).with(drawers[1]).and_return(true)

      tournament.should_receive(:players).and_return(winners + drawers + losers)
      tournament.should_receive(:create_match).with(winners[0], winners[1])
      tournament.should_receive(:create_match).with(drawers[0], losers[0])
      tournament.should_receive(:create_match).with(drawers[1], losers[1])

      subject.generate_matches
    end

    it 'should swap with the score group above if there is still an illegal match' do
      player200 = mock_model(Player, match_score: 6, played?: false)
      players110 = 3.times.map { mock_model(Player, match_score: 4, played?: false) }
      players011 = 2.times.map { mock_model(Player, match_score: 1, played?: false) }

      player200.stub(:played?).with(players110[1]).and_return(true)
      player200.stub(:played?).with(players110[0]).and_return(true)

      players110[0].stub(:played?).with(players110[2]).and_return(true)
      players110[0].stub(:played?).with(player200).and_return(true)

      players110[1].stub(:played?).with(player200).and_return(true)
      players110[1].stub(:played?).with(players011[0]).and_return(true)

      players110[2].stub(:played?).with(players110[0]).and_return(true)
      players110[2].stub(:played?).with(players011[1]).and_return(true)

      players011[0].stub(:played?).with(players011[1]).and_return(true)
      players011[0].stub(:played?).with(players110[1]).and_return(true)

      players011[1].stub(:played?).with(players011[0]).and_return(true)
      players011[1].stub(:played?).with(players110[2]).and_return(true)

      tournament.should_receive(:players).and_return([player200, *players110, *players011])
      tournament.should_receive(:create_match).with(player200, players110[2])
      tournament.should_receive(:create_match).with(players011[0], players110[0])
      tournament.should_receive(:create_match).with(players110[1], players011[1])

      subject.generate_matches
    end
  end
end

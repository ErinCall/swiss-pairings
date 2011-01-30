require 'spec_helper'

describe SwissPairer do
  describe '#generate_matches' do
    subject { SwissPairer.new(tournament) }
    let(:tournament) { Factory.create(:tournament) }

    before(:each) do
      i = 0
      subject.stub(:rand) { |max| max.nil? ? i += 1 : 0 }
    end

    it 'should match players by match score' do
      winners = 2.times.map { Factory.create(:player, tournament: tournament) }
      losers = 2.times.map { Factory.create(:player, tournament: tournament) }

      Factory.create(:match, tournament: tournament, player_1: winners[0], player_2: losers[0], player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: winners[1], player_2: losers[1], player_1_wins: 1)

      tournament.should_receive(:create_match).with(*winners)
      tournament.should_receive(:create_match).with(*losers)

      subject.generate_matches
    end

    it 'should give a bye if there is an uneven number of players' do
      players = 3.times.map { Factory.create(:player, tournament: tournament) }

      tournament.should_receive(:create_match).with(players[0], players[1])
      tournament.should_receive(:create_match).with(players[2], nil)

      subject.generate_matches
    end

    it 'should move players up from a lower group if there is an odd number in a group' do
      winner = Factory.create(:player, tournament: tournament)
      drawers = 2.times.map { Factory.create(:player, tournament: tournament) }
      loser = Factory.create(:player, tournament: tournament)

      Factory.create(:match, tournament: tournament, player_1: winner, player_2: loser, player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: drawers[0], player_2: drawers[0], draws: 0)

      tournament.should_receive(:create_match).with(winner, drawers[0])
      tournament.should_receive(:create_match).with(drawers[1], loser)

      subject.generate_matches
    end

    it 'should swap within a score group if there is an illegal match' do
      drawers = 4.times.map { Factory.create(:player, tournament: tournament) }

      Factory.create(:match, tournament: tournament, player_1: drawers[0], player_2: drawers[1], draws: 1)
      Factory.create(:match, tournament: tournament, player_1: drawers[2], player_2: drawers[3], draws: 1)

      tournament.should_receive(:create_match).with(drawers[0], drawers[2])
      tournament.should_receive(:create_match).with(drawers[1], drawers[3])

      subject.generate_matches
    end

    it 'should swap with the score group below if there is still an illegal match' do
      winners = 2.times.map { Factory.create(:player, tournament: tournament) }
      drawers = 2.times.map { Factory.create(:player, tournament: tournament) }
      losers = 2.times.map { Factory.create(:player, tournament: tournament) }

      Factory.create(:match, tournament: tournament, player_1: winners[0], player_2: losers[0], player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: drawers[0], player_2: drawers[1], draws: 1)
      Factory.create(:match, tournament: tournament, player_1: winners[1], player_2: losers[1], player_1_wins: 1)

      tournament.should_receive(:create_match).with(winners[0], winners[1])
      tournament.should_receive(:create_match).with(drawers[0], losers[0])
      tournament.should_receive(:create_match).with(drawers[1], losers[1])

      subject.generate_matches
    end

    it 'should swap with the score group above if there is still an illegal match' do
      player200 = Factory.create(:player, tournament: tournament)
      players110 = 3.times.map { Factory.create(:player, tournament: tournament) }
      players011 = 2.times.map { Factory.create(:player, tournament: tournament) }

      Factory.create(:match, tournament: tournament, player_1: player200, player_2: players110[1], player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: players110[0], player_2: players110[2], player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: players011[0], player_2: players011[1], draws: 1)

      Factory.create(:match, tournament: tournament, player_1: player200, player_2: players110[0], player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: players110[1], player_2: players011[0], player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: players110[2], player_2: players011[1], player_1_wins: 1)

      tournament.should_receive(:create_match).with(player200, players110[2])
      tournament.should_receive(:create_match).with(players011[0], players110[0])
      tournament.should_receive(:create_match).with(players110[1], players011[1])

      subject.generate_matches
    end

    it 'should be able to swap byes' do
      winner = Factory.create(:player, tournament: tournament)
      loser = Factory.create(:player, tournament: tournament)
      drawers = 2.times.map { Factory.create(:player, tournament: tournament) }
      bye = Factory.create(:player, tournament: tournament)

      Factory.create(:match, tournament: tournament, player_1: winner, player_2: loser, player_1_wins: 1)
      Factory.create(:match, tournament: tournament, player_1: drawers[0], player_2: drawers[1], draws: 1)
      Factory.create(:match, tournament: tournament, player_1: bye, player_2: nil)

      tournament.should_receive(:create_match).with(winner, bye)
      tournament.should_receive(:create_match).with(drawers[0], loser)
      tournament.should_receive(:create_match).with(drawers[1], nil)

      subject.generate_matches
    end
  end
end

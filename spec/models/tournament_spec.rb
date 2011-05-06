require 'spec_helper'

describe Tournament do
  describe 'validations' do
    before(:each) { subject.save }

    it 'should require a name' do
      subject.errors[:name].should include("can't be blank")
    end
  end

  describe '#started?' do
    it 'should return false if the current round is 0' do
      tournament = Factory.create(:tournament, current_round: 0)

      tournament.should_not be_started
    end

    it 'should return false if the current round is greater than 0' do
      tournament = Factory.create(:tournament, current_round: 1)

      tournament.should be_started
    end
  end

  describe '#calculate_total_rounds' do
    subject { Factory.create(:tournament) }

    it 'should use the ceiling of the binary log to determine the number of rounds needed' do
      5.times.map { Factory.create(:player, tournament: subject) }

      subject.calculate_total_rounds

      subject.total_rounds.should == 3
    end
  end

  describe '#unfinished_matches' do
    it 'should return the matches for the current round that have not had results entered' do
      tournament = Factory.create(:tournament, current_round: 1)
      players = 5.times.map { Factory.create(:player) }
      unfinished_match = tournament.matches.create(
        round: 1,
        player_1: players[0],
        player_2: players[1]
      )
      tournament.matches.create(
        winner: 1,
        round: 1,
        player_1: players[2],
        player_2: players[3]
      )
      tournament.matches.create(
        round: 1,
        player_1: players[4]
      )

      tournament.unfinished_matches.to_a.should == [unfinished_match]
    end
  end

  describe '#finished_rounds' do
    let(:subject) { Factory.create(:tournament, current_round: 1) }
    let(:players) { 3.times.map { Factory.create(:player, tournament: subject) } }
    it 'should return the current round, less one, if there are unfinished matches' do
      subject.matches.create(round: 1, player_1: players[0], player_2: players[1])
      subject.matches.create(round: 1, player_1: players[2])

      subject.finished_rounds.should == 0
    end

    it 'should return the current round if all matches are finished' do
      subject.matches.create(winner: 1, round: 2, player_1: players[0], player_2: players[1])
      subject.matches.create(round: 2, player_1: players[2])

      subject.finished_rounds.should == 1
    end
  end

  describe '#finished?' do
    let(:tournament) { Factory.create(:tournament, current_round: 1, total_rounds: 2) }
    it 'should be false if there are unfinished rounds' do
      tournament.finished?.should be_false

    end
    it 'should be true if all rounds are finished' do
      tournament.next_round
      tournament.finished?.should be_true
    end
  end

  describe '#underway?' do
    let(:tournament) { Factory.create(:tournament, current_round: 0, total_rounds: 2) }
    it "should be false if the tournament hasn't started" do
      tournament.underway?.should be_false
    end

    it "should be true if the tournament has started but there are unfinished rounds" do
      tournament.next_round
      tournament.underway?.should be_true
    end

    it "should be false if the tournament has finished" do
      2.times {tournament.next_round}
      tournament.underway?.should be_false
    end
  end

  describe '#current_matches' do
    it 'should return the matches for the current round' do
      tournament = Factory.create(:tournament, current_round: 2)
      current_match = tournament.matches.create(round: 2)
      tournament.matches.create(winner: 1, round: 1)

      tournament.current_matches.to_a.should == [current_match]
    end
  end

  describe '#matches_for_player' do
    it 'should search its matches for ones played by the given player' do
      tournament = Factory.create(:tournament)
      player = Factory.create(:player, tournament: tournament)
      expected_matches = [
        Factory.create(:match, tournament: tournament, player_1: player),
        Factory.create(:match, tournament: tournament, player_2: player)
      ]
      Factory.create(:match, tournament: tournament)

      tournament.matches_for_player(player).should == expected_matches
    end
  end

  describe '#create_match' do
    let(:tournament) { Factory.create(:tournament, current_round: 1) }

    it 'should create a match with the given players for the current round' do
      players = 2.times.map { Factory.create(:player, tournament: tournament) }

      match = tournament.create_match(*players)

      match.player_1.should == players[0]
      match.player_2.should == players[1]
      match.round.should == 1
    end

    it 'should handle byes' do
      player = Factory.create(:player, tournament: tournament)

      match = tournament.create_match(player, nil)

      match.player_1.should == player
      match.player_2.should be_nil
    end
  end

  describe '#next_round' do
    it 'should increment the current round' do
      tournament = Factory.create(:tournament, current_round: 1)

      tournament.next_round

      tournament.current_round.should == 2
    end
  end

  describe '#results' do
    let(:subject) { Factory.create(:tournament, current_round:2, total_rounds: 2) }

    it 'should return the players in results order' do
      players = 4.times.map { Factory.create(:player, tournament: subject) }
      players.each_with_index { |player, index| player.stub(:match_score) {index} }

    subject.results.should == players.reverse
    end
  end
end

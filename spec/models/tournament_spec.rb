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
        player_1_id: players[0].id,
        player_2_id: players[1].id
      )
      tournament.matches.create(
        winner: 1,
        round: 1,
        player_1_id: players[2].id,
        player_2_id: players[3].id
      )
      tournament.matches.create(
        round: 1,
        player_1_id: players[4].id
      )

      tournament.unfinished_matches.to_a.should == [unfinished_match]
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
      expected_matches = [
        mock_model(Match, player_1_id: 'foo'),
        mock_model(Match, player_1_id: 'bar', player_2_id: 'foo'),
      ]
      tournament.should_receive(:matches).and_return([
        *expected_matches,
        mock_model(Match, player_1_id: 'bar', player_2_id: 'baz')
      ])

      tournament.matches_for_player(mock_model(Player, id: 'foo')).should == expected_matches
    end
  end

  describe '#create_match' do
    let(:tournament) { Factory.create(:tournament, current_round: 1) }

    it 'should create a match with the given players for the current round' do
      players = 2.times.map { Factory.create(:player, tournament: tournament) }

      match = tournament.create_match(*players)

      match.player_1_id.should == players[0].id
      match.player_2_id.should == players[1].id
      match.round.should == 1
    end

    it 'should handle byes' do
      player = Factory.create(:player, tournament: tournament)

      match = tournament.create_match(player, nil)

      match.player_1_id.should == player.id
      match.player_2_id.should be_nil
    end
  end

  describe '#next_round' do
    it 'should increment the current round' do
      tournament = Factory.create(:tournament, current_round: 1)

      tournament.next_round

      tournament.current_round.should == 2
    end
  end
end

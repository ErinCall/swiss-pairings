require 'spec_helper'

describe Tournament do
  describe 'validations' do
    before(:each) { subject.save }

    it 'should require a name' do
      subject.errors[:name].should include("can't be blank")
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

  describe '#generate_matches' do
    subject { Factory.create(:tournament, current_round: 1) }
    it 'should match players by match score' do
      winners = 2.times.map { mock_model(Player, match_score: 3) }
      losers = 2.times.map { mock_model(Player, match_score: 0) }
      subject.should_receive(:players).and_return(winners + losers)

      subject.generate_matches

      should have_matches_for_round(2, winners, losers)
    end

    it 'should give a bye if there is an uneven number of players' do
      subject.should_receive(:players).and_return(3.times.map { mock_model(Player, match_score: 0) })

      subject.generate_matches

      subject.current_matches[1].player_2_id.should be_nil
    end

    it 'should move players up from a lower group if there is an odd number in a group' do
      winner = mock_model(Player, match_score: 3)
      drawers = 2.times.map { mock_model(Player, match_score: 1) }
      loser = mock_model(Player, match_score: 0)
      subject.should_receive(:players).and_return([winner, *drawers, loser])

      subject.generate_matches

      subject.current_matches.count.should == 2
    end
  end

  describe '#unfinished_matches' do
    it 'should return the matches for the current round that have not had results entered' do
      tournament = Factory.create(:tournament, current_round: 1)
      unfinished_match = tournament.matches.create(round: 1)
      tournament.matches.create(winner: 1, round: 1)

      tournament.unfinished_matches.to_a.should == [unfinished_match]
    end
  end

  describe '#current_matches' do
    it 'should return the matches for the current round that have not had results entered' do
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
end
